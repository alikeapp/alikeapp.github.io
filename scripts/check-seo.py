#!/usr/bin/env python3
"""Check rendered localization, JSON-LD and search metadata without dependencies."""
import html
from html.parser import HTMLParser
import json
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET


class Page(HTMLParser):
    def __init__(self, source):
        super().__init__()
        self.links = []
        self.meta = {}
        self.scripts = []
        self.capture = False
        self.feed(source)

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'link':
            self.links.append(attrs)
        if tag == 'meta':
            self.meta[attrs.get('name', attrs.get('property'))] = attrs.get('content')
        if tag == 'script' and attrs.get('type') == 'application/ld+json':
            self.capture = True
            self.scripts.append('')

    def handle_data(self, data):
        if self.capture:
            self.scripts[-1] += data

    def handle_endtag(self, tag):
        if tag == 'script':
            self.capture = False


def check(site, config):
    errors = []
    def require(condition, message):
        if not condition:
            errors.append(message)

    config_text = config.read_text()
    languages = [x.strip().strip('\"\'') for x in re.search(r'^languages:\s*\[([^]]+)\]', config_text, re.M)[1].split(',')]
    data_dir = Path(__file__).resolve().parent.parent / '_data'
    pages = ['home','privacy','terms','support','compare','guide_similar','guide_storage']
    routes = {}
    tags = {}
    for lang in languages:
        data = (data_dir / (lang + '.yml')).read_text()
        tags[lang] = re.search(r'^locale_tag:\s*(\S+)', data, re.M)[1]
        for key in pages:
            routes[lang,key] = re.search(r'^'+key+r'_url:\s*(\S+)', data,re.M)[1]
    origin = re.search(r'^url:\s*[\"\']?([^\"\'\s]+)', config_text,re.M)[1]
    for lang in languages:
        for key in pages:
            path = site / routes[lang,key].strip('/') / 'index.html'
            if not path.exists():
                require(False, f'Missing SEO page: {routes[lang,key]}')
                continue
            source = path.read_text()
            page = Page(source)
            expected = [(tags[l],origin+routes[l,key]) for l in languages]
            if 'es' in languages:
                expected.append(('es-419',origin+routes['es',key]))
            expected.append(('x-default',origin+routes['en',key]))
            actual = [(a.get('hreflang'),a.get('href')) for a in page.links if a.get('rel') == 'alternate']
            require(sorted(actual) == sorted(expected), f'{routes[lang,key]}: incorrect hreflang set or document target')
            require(page.meta.get('apple-itunes-app') == 'app-id=6798399598',f'{routes[lang,key]}: missing Smart App Banner')
            require(bool(page.meta.get('description')),f'{routes[lang,key]}: missing description')
            blocks = []
            for block in page.scripts:
                try:
                    value = json.loads(block)
                    require('aggregateRating' not in value,f'{routes[lang,key]}: unexpected rating')
                    blocks.append(value)
                except json.JSONDecodeError as error:
                    require(False,f'{routes[lang,key]}: invalid JSON-LD: {error}')
            types = [b.get('@type') for b in blocks]
            wanted = ['SoftwareApplication','FAQPage'] if key == 'home' else ['BreadcrumbList']
            require(types == wanted,f'{routes[lang,key]}: unexpected JSON-LD types {types}')
            if key == 'home' and types == wanted:
                app,faq = blocks
                require(app.get('operatingSystem') == 'iOS 17.0 or later',f'{lang}: incorrect operatingSystem')
                require(app.get('offers',{}).get('price') == '0',f'{lang}: missing free offer')
                def text(value):
                    return html.unescape(re.sub('<[^>]+>','',value)).strip()
                questions = [text(v) for v in re.findall(r'<summary class="faq__q">(.*?)</summary>',source,re.S)]
                answers = [text(v) for v in re.findall(r'<div class="faq__a"><p>(.*?)</p></div>',source,re.S)]
                entities = faq.get('mainEntity',[])
                require([(v.get('name'),v.get('acceptedAnswer',{}).get('text')) for v in entities] == list(zip(questions,answers)) and bool(questions),f'{lang}: FAQ does not match visible content')
                require(len(re.search(r'<title>(.*?)</title>',source,re.S)[1]) <= 60,f'{lang}: title exceeds 60 characters')
                require(len(page.meta['description']) <= 155,f'{lang}: description exceeds 155 characters')
            elif key != 'home' and types == wanted:
                items = blocks[0].get('itemListElement',[])
                require(len(items)==2 and [v.get('position') for v in items]==[1,2] and [v.get('item') for v in items]==[origin+routes[lang,'home'],origin+routes[lang,key]],f'{routes[lang,key]}: incorrect breadcrumbs')
            if key in ('guide_similar','guide_storage'):
                app_links = [a for a in re.findall(r'<a\b[^>]*href="([^"]+)"', source) if a.startswith('https://apps.apple.com/')]
                require(len(app_links)==1,f'{routes[lang,key]}: expected one App Store link')
    ns={'s':'http://www.sitemaps.org/schemas/sitemap/0.9','x':'http://www.w3.org/1999/xhtml'}
    tree=ET.parse(site/'sitemap.xml')
    urls=tree.findall('s:url',ns)
    require(len(urls)==len(routes),'sitemap: incorrect page count')
    for url in urls:
        loc=url.findtext('s:loc',namespaces=ns)
        lastmod=url.findtext('s:lastmod',namespaces=ns)
        require(bool(lastmod and re.fullmatch(r'\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d(?:Z|[+-]\d\d:\d\d)',lastmod)),f'{loc}: missing or invalid lastmod')
        require(len(url.findall('x:link',ns))==len(languages)+2,f'{loc}: sitemap alternates missing')
    for error in errors:
        print('::error::'+error,file=sys.stderr)
    if not errors:
        print(f'  ok  SEO metadata, hreflang, JSON-LD, FAQ and sitemap for {len(routes)} pages')
    return bool(errors)


if __name__ == '__main__':
    sys.exit(check(Path(sys.argv[1]),Path(sys.argv[2])))
