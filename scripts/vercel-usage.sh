#!/usr/bin/env bash
# Vercel の利用量を確認し、上限に近づいたら・止められたら Issue で知らせる（uptime.yml から1時間に1回呼ぶ）。
# 2026-11-06、無料プラン（Hobby）の「計算時間 月4時間」を超えて CRM・オンライン予約がチームごと止められたのに、
# 事前の警告が誰にも届かなかったため追加。
# 2026-11-06 に CRM・オンライン予約は Google Cloud Run へ移行。Vercel に残っているのは AI姿勢分析（ai.deeq.jp）だけ。
#
# 無料プランでは API から計算時間そのものは読めない（有料プラン限定）。そこで「呼び出し回数」から推定する。
# 物差し: 停止直前の30日間は約44万回の呼び出しで4時間に達した → 1回あたり約32ミリ秒（2026-11-06実測）。
# 必要な秘密情報: VERCEL_USAGE_TOKEN（読むだけに使う。ログには一切出さない）
set -u
: "${VERCEL_USAGE_TOKEN:?}" "${REPO:?}" "${RUN_URL:?}"
TEAM="team_LUoC1GvhlhJjOEw8rKxfxo9S"
CPU_MS_PER_CALL=32
NOW=$(TZ=Asia/Tokyo date '+%m/%d %H:%M')

api() { curl -sS -m 30 -H "Authorization: Bearer $VERCEL_USAGE_TOKEN" "https://api.vercel.com$1"; }

team=$(api "/v2/teams/$TEAM") || { echo "::warning::Vercel に接続できませんでした"; exit 0; }
plan=$(jq -r '.billing.plan // "?"' <<<"$team")
block_reason=$(jq -r '.softBlock.reason // empty' <<<"$team")
block_type=$(jq -r '.softBlock.blockedDueToOverageType // empty' <<<"$team")
unpause=$(jq -r '.softBlock.unpauseAt // empty' <<<"$team")
if jq -e '.error' <<<"$team" >/dev/null; then
  echo "::warning::Vercel の確認に失敗: $(jq -r '.error.code' <<<"$team")（鍵の期限切れの可能性）"
  exit 0
fi

level=""; title=""; detail=""
if [ -n "$block_reason" ]; then
  until_jst=$( [ -n "$unpause" ] && TZ=Asia/Tokyo date -d "@$((unpause/1000))" '+%m/%d %H:%M' || echo "不明")
  level="停止"
  title="【緊急】Vercel の利用上限で AI姿勢分析（ai.deeq.jp）が止められています（${NOW}）"
  detail="Vercel がチーム全体を止めました（理由: ${block_reason} / ${block_type}）。
何もしなければ ${until_jst}（日本時間）まで止まったままです。
すぐ戻すには Vercel を Pro（月20ドル）にするか、Pro の無料お試しを使います。慎に「Vercelの停止を解除したい」と伝えてください。"
elif [ "$plan" = "hobby" ]; then
  from=$(date -u -d '30 days ago' '+%Y-%m-%dT00:00:00.000Z'); to=$(date -u '+%Y-%m-%dT%H:%M:%S.000Z')
  usage=$(api "/v2/usage?teamId=$TEAM&type=requests&from=$from&to=$to") || exit 0
  calls=$(jq '[.data[] | .function_invocation_successful_count + .function_invocation_error_count + .function_invocation_timeout_count] | add // 0' <<<"$usage")
  cpu_pct=$(( calls * CPU_MS_PER_CALL * 100 / (4 * 3600 * 1000) ))
  call_pct=$(( calls * 100 / 1000000 ))
  pct=$(( cpu_pct > call_pct ? cpu_pct : call_pct ))
  echo "$NOW Vercel 直近30日: 呼び出し ${calls} 回 / 推定計算時間 上限の ${cpu_pct}% / 呼び出し回数 上限の ${call_pct}%"
  if [ "$pct" -ge 75 ]; then level="警告"; elif [ "$pct" -ge 50 ]; then level="注意"; fi
  if [ -n "$level" ]; then
    title="【${level}】Vercel の無料枠を ${pct}% 使っています（${NOW}）"
    detail="直近30日の呼び出しは ${calls} 回で、推定の計算時間は上限（月4時間）の ${cpu_pct}% です。
100% に達するとチーム全体が30日間止められ、AI姿勢分析（ai.deeq.jp）が使えなくなります（2026-11-06 に実際に発生。CRM・オンライン予約は同日 Cloud Run へ移行済み）。
慎に「Vercelの使用量を減らすか、Pro に切り替えるか決めたい」と伝えてください。"
  fi
fi

gh label create usage -R "$REPO" -c D93F0B -d "利用量の上限に近い・止められた" 2>/dev/null || true
open_num=$(gh issue list -R "$REPO" -l usage -s open --json number -q '.[0].number' 2>/dev/null || true)
open_title=$(gh issue list -R "$REPO" -l usage -s open --json title -q '.[0].title' 2>/dev/null || true)
if [ -n "$level" ]; then
  if [ -z "$open_num" ]; then
    gh issue create -R "$REPO" -l usage --title "$title" --body "@qitano-inc ${detail}

実行: $RUN_URL" || echo "::warning::Issue を作れませんでした"
  elif ! grep -q "【${level}】" <<<"$open_title"; then
    # 段階が変わった（注意→警告→停止）ときだけ、同じ Issue に書き足して題名も変える
    gh issue edit "$open_num" -R "$REPO" --title "$title" >/dev/null || true
    gh issue comment "$open_num" -R "$REPO" -b "@qitano-inc ${detail}" || true
  fi
elif [ -n "$open_num" ]; then
  gh issue close "$open_num" -R "$REPO" -c "@qitano-inc ${NOW}（日本時間）に確認し、Vercel の利用量は安全な範囲に戻っていました。" || true
fi
