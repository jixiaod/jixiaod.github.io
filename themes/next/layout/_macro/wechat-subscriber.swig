{% if theme.wechat_subscriber.enabled %}
<div id="wechat_subscriber">
    <img id="wechat_subscriber_qcode" src="{{ theme.wechat_subscriber.qcode }}" alt="{{ theme.author }} wechat" style="width: 200px; max-width: 100%;"/>
    <div>{{ theme.wechat_subscriber.description }}</div>
</div>
{% endif %}
