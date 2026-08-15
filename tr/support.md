---
layout: page
title: Destek
permalink: /tr/support/
lang: tr
page_key: support
description: "Alike için destek. Hesap yok, destek talebi sistemi yok — bize bir e-posta yaz, yanıt al."
---

{%- assign t = site.data[page.lang] %}

{{ t.support.subtitle }}

## {{ t.support.contact_title }}

{{ t.support.contact_body }}

[{{ site.contact_email }}](mailto:{{ site.contact_email }}?subject=Alike%20Support)

{{ t.support.response }}

## {{ t.support.before_title }}

{{ t.support.before_body }}

## {{ t.support.bug_title }}

{{ t.support.bug_body }}

{{ t.support.details_title }}

{% for item in t.support.details %}- {{ item }}
{% endfor %}
## {{ t.support.privacy_title }}

{{ t.support.privacy_body }}

- [{{ t.footer.privacy }}]({{ t.privacy_url | relative_url }})
- [{{ t.footer.terms }}]({{ t.terms_url | relative_url }})

## {{ t.support.subs_title }}

{{ t.support.subs_body }}

- {{ t.support.subs_manage }}
- {{ t.support.subs_refund_prefix }} [{{ t.support.subs_refund_link }}](https://support.apple.com/HT204084)
- {{ t.support.subs_restore }}
