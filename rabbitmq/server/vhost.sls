{%- from "rabbitmq/map.jinja" import server with context %}
{%- if server.enabled %}

{%- for host_name, host in server.get('host', {}).iteritems() %}

{%- if host.enabled %}

{%- if host_name != '/' %}
rabbitmq_vhost_{{ host_name }}:
  rabbitmq_vhost.present:
  - name: {{ host_name }}
  - require:
    - service: rabbitmq_service
{%- endif %}

{%- if salt['pkg.version_installed'](server.pkg) %}

{%- if not salt['rabbitmq.user_exists'](host.user) %}

rabbitmq_user_{{ host.user }}:
  rabbitmq_user.present:
  - name: {{ host.user }}
  - password: {{ host.password }}
  - force: true
  {%- if host_name != '/' %}
  - require:
    - rabbitmq_vhost_{{ host_name }}
  {%- endif %}
  - perms:
    - '{{ host_name }}':
      - '.*'
      - '.*'
      - '.*'

{%- endif %}

{%- else %}

rabbitmq_user_{{ host.user }}:
  rabbitmq_user.present:
  - name: {{ host.user }}
  - password: {{ host.password }}
  - force: true
  {%- if host_name != '/' %}
  - require:
    - rabbitmq_vhost_{{ host_name }}
  {%- endif %}
  - perms:
    - '{{ host_name }}':
      - '.*'
      - '.*'
      - '.*'

{%- endif %}

{%- for policy in host.get('policies', []) %}

rabbitmq_policy_{{ host_name }}_{{ policy.name }}:
  rabbitmq_policy.present:
  - name: {{ policy.name }}
  - pattern: {{ policy.pattern }}
  - definition: {{ policy.definition|json }}
  - vhost: {{ host_name }}
  - require:
    - service: rabbitmq_service

{%- endfor %}

{%- else %}

rabbitmq_vhost_{{ host_name }}:
  rabbitmq_vhost.absent:
  - name: {{ host_name }}
  - require:
    - service: rabbitmq_service

rabbitmq_user_{{ host.user }}:
  rabbitmq_user.absent:
  - name: {{ host.user }}
  - require:
    - service: rabbitmq_service

{%- endif %}

{%- endfor %}

{%- endif %}
