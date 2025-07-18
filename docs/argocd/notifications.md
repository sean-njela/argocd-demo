# 🔔 **Argo CD Notifications**

---

🎯 **What Is It?**

A mechanism for sending real-time updates (e.g. via Slack, email, webhooks) when changes occur in Argo CD apps.

---

🧠 **Why Use It?**

* Alerts stakeholders/devs on app syncs, health changes, or failures
* Prevents silent failures in CD pipelines
* Enables traceability and rapid incident response
* Integrates GitOps events into team workflows

---

🏠 **Real-World USE CASE**

In a DevOps team managing microservices with Argo CD, when a deployment fails due to drift or Helm chart issues, a Slack alert is sent instantly. This lets the responsible dev fix it **before it hits production or CI breaks**.

---

🔧 **How It Works**

1. Install `argocd-notifications` controller (either bundled with Argo CD or as a sidecar)
2. Configure **Triggers**: conditions like “sync failed”, “health degraded”
3. Set up **Templates**: what the message looks like
4. Define **Subscriptions**: who gets notified (e.g. Slack, Teams, Email)
5. Apply config as Kubernetes `ConfigMap` or `Secret`

---

💡 **Code Example (K8s Manifest Snippet)**

```yaml
# notifications-cm.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-notifications-cm
  labels:
    app.kubernetes.io/name: argocd-notifications-cm
data:
  service.slack: |
    token: $slack-token   # from Secret
  trigger.on-sync-failed: |
    - when: app.status.operationState.phase in ['Failed']
      send: [slack-message]
  template.slack-message: |
    message: |
      Application {{.app.metadata.name}} sync **FAILED**
      🚨 Reason: {{.app.status.operationState.message}}
```

```yaml
# notifications-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
stringData:
  slack-token: "<xoxb-your-slack-bot-token>"
```

---

🔍 **Key Strengths**

* Native GitOps integration
* Lightweight (controller runs as small Go service)
* Customisable triggers and messages
* Works with any messaging system via webhook

---

⚠️ **Watch Outs & Critical Analysis**

* **Lack of Granular ACLs**: All notification configs are global
* **Hard to Test Locally**: Requires real Argo CD state changes
* **Limited Built-in Templates**: Must build message templates from scratch
* **Message Spam Risk**: Poor trigger logic = notification fatigue
* **Alert Routing Complexity**: Slack channels or email groups may need to be tightly controlled

---

🔀 **Best Practical Approach**

✅ Use only **critical triggers** (sync failures, degraded health)
✅ Create modular templates to reuse messages
✅ Route alerts to a central **DevOps Slack channel**, not individuals
✅ Leverage webhooks for forwarding to incident tools (e.g. PagerDuty)
✅ Validate templates using Argo CD CLI (`argocd-notifications template render`)

🚫 Do **not** notify on every sync—creates noise
🚫 Avoid Slack mentions in production unless tied to alerts/escalation policies

---

📚 **Related Topics**

* Argo CD (core)
* GitOps
* Prometheus Alertmanager (if using metric-based alerting)
* Kubernetes ConfigMaps/Secrets
* Slack Bots/Webhooks

---

Many intergrations are available but we will be using slack for this example. But the process is the same for other integrations.

First create a slack app using `api.slack.com/apps?deleted=1` and selecting the from scratch option. Name it argocd, choose a workspace and head to oauth to grant the app the necessary permissions to post to slack channels under `bot token` scope. (chat:write and chat:write.customise). Then scroll up and click install to workspace. 

Copy the bot token and save it in a secret file. `0-notifications-secret.yaml`. The secret name and namespace must be `argocd-notifications-secret` and `argocd` respectively. For the configmap `0-notifications-cm.yaml` as well the name and namespace must be `argocd-notifications-cm` and `argocd` respectively.

In the app `my-argocd-app2` we will need to add annotations to enable notifications.

```yaml
notifications.argoproj.io/subscribe.on-deployed.slack: alerts 
notifications.argoproj.io/subscribe.on-sync-failed.slack: alerts 
```

There are many more than this. You can find them in the [Argo CD Notifications](https://argoproj.github.io/argo-cd/notifications/) documentation.

Now add a channel in slack named `alerts` and add the bot to it. Most of teh time it will be private but for this example we will use public. We will need to add the bot to the channel ( `hey @<bot name>` in the channel ) and then add when prompted.

Then apply the secret, configmp.