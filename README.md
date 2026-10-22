# deeq-status

DEEQ のサイトが止まっていないかを、10分ごとに外から確認するだけのリポジトリです（2026-10-22 開設）。

- 確認先: CRM（crm.deeq.jp）・オンライン予約（yoyaku.deeq.jp）・AI姿勢分析（ai.deeq.jp）・deeq.jp・qitano.com
- 止まっていたら1分おいてもう一度確認し、それでも止まっていればワークフローを失敗させます（GitHub からメール通知）
- 公開されている URL しか扱いません（秘密情報はありません）。公開リポジトリにしているのは、GitHub Actions を無料で何度でも動かせるためです
- GitHub は60日間更新のない公開リポジトリの定期実行を止めるため、月に1回 `heartbeat.txt` を更新します

管理: QITANO株式会社（DEEQ AIチーム）。初動手順は DEEQ 社内の `AI_TEAM/guidelines/34_incident_response_playbook.md`。
