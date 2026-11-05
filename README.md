# deeq-status

DEEQ のサイトが止まっていないかを、10分ごとに外から確認するだけのリポジトリです（2026-10-22 開設）。

- 確認先: CRM（crm.deeq.jp）・オンライン予約（yoyaku.deeq.jp）・AI姿勢分析（ai.deeq.jp）・deeq.jp・qitano.com
- 定期処理（来店前リマインド・予約通知の再送・容量チェックなど全25件）が予定どおり動いているかも、`https://crm.deeq.jp/api/health/crons` で確認します（2026-11-05 追加）。返すのは処理の名前と止まっているかどうかだけです
- Vercel の利用量も1時間に1回確認し、無料枠の推定50%で「注意」、75%で「警告」、止められたら「緊急」の Issue（ラベル usage）でお知らせします。サイトが「402 Payment required」で止まった場合は、利用上限が原因だと Issue に明記します（2026-11-06 追加。秘密情報 VERCEL_USAGE_TOKEN が必要）
- 止まっていたら1分おいてもう一度確認し、それでも応答がなければ Issue を作って @qitano-inc にメールで通知。復旧したら同じ Issue に書き込んで閉じます
- GitHub の定期実行は混雑時に数時間遅れるため、1回の実行の中で10分ごとの確認を約5時間45分くり返し、次の回に引き継ぎます
- 公開されている URL しか扱いません（秘密情報はありません）。公開リポジトリにしているのは、GitHub Actions を無料で何度でも動かせるためです
- GitHub は60日間更新のない公開リポジトリの定期実行を止めるため、月に1回 `heartbeat.txt` を更新します

管理: QITANO株式会社（DEEQ AIチーム）。初動手順は DEEQ 社内の `AI_TEAM/guidelines/34_incident_response_playbook.md`。
