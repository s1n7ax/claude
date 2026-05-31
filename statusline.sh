#!/usr/bin/env bash
input=$(cat)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

fmt() {
  awk -v n="$1" 'BEGIN{
    if (n>=1e9) printf "%.2fB", n/1e9;
    else if (n>=1e6) printf "%.2fM", n/1e6;
    else if (n>=1e3) printf "%.1fK", n/1e3;
    else printf "%d", n;
  }'
}

if [[ -n "$transcript" && -f "$transcript" ]]; then
  read -r in_tot cache_c cache_r out_tot ctx_last < <(
    jq -rs '
      [.[] | select(.message.usage != null) | .message.usage] as $u
      | ($u | map(.input_tokens // 0) | add // 0) as $in
      | ($u | map(.cache_creation_input_tokens // 0) | add // 0) as $cc
      | ($u | map(.cache_read_input_tokens // 0) | add // 0) as $cr
      | ($u | map(.output_tokens // 0) | add // 0) as $out
      | ($u | last) as $l
      | (($l.input_tokens // 0) + ($l.cache_creation_input_tokens // 0) + ($l.cache_read_input_tokens // 0)) as $ctx
      | "\($in) \($cc) \($cr) \($out) \($ctx)"
    ' "$transcript" 2>/dev/null
  )
  : "${in_tot:=0}" "${cache_c:=0}" "${cache_r:=0}" "${out_tot:=0}" "${ctx_last:=0}"
  total=$((in_tot + cache_c + cache_r + out_tot))
  printf 'ctx %s | in %s | out %s | cache %s | total %s' \
    "$(fmt "$ctx_last")" \
    "$(fmt "$in_tot")" \
    "$(fmt "$out_tot")" \
    "$(fmt $((cache_c + cache_r)))" \
    "$(fmt "$total")"
else
  printf 'ctx 0 | in 0 | out 0 | cache 0 | total 0'
fi
