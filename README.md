# deeq-status

DEEQ のサイトが止まっていないかを、10分ごとに外から確認するだけのリポジトリです（2026-10-22 開設）。

- 確認先: CRM（crm.deeq.jp）・オンライン予約（yoyaku.deeq.jp）・AI姿勢分析（ai.deeq.jp）・deeq.jp・qitano.com
- 止まっていたら1分おいてもう一度確認し、それでも応答がなければ Issue を作って @qitano-inc にメールで通知。復旧したら同じ Issue に書き込んで閉じます
- GitHub の定期実行は混雑時に数時間遅れるため、1回の実行の中で10分ごとの確認を約5時間45分くり返し、次の回に引き継ぎます
- 公開されている URL しか扱いません（秘密情報はありません）。公開リポジトリにしているのは、GitHub Actions を無料で何度でも動かせるためです
- GitHub は60日間更新のない公開リポジトリの定期実行を止めるため、月に1回 `heartbeat.txt` を更新します

管理: QITANO株式会社（DEEQ AIチーム）。初動手順は DEEQ 社内の `AI_TEAM/guidelines/34_incident_response_playbook.md`。
