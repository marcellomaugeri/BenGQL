#!/usr/bin/env bash
# Minimal positive/negative coverage table.
# Usage:
#   ./positive_negative_coverage.sh ./results/evomaster_vs_graphqler
# Output format:
#   Case | GraphQLer Pos | GraphQLer Neg | EvoMaster Pos | EvoMaster Neg

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <experiment_results_folder>" >&2
  exit 1
fi
ROOT="$1"
[[ -d $ROOT ]] || { echo "Folder not found: $ROOT" >&2; exit 1; }

percent(){ local n=$1 d=$2; if [[ $d -eq 0 ]]; then echo "100.00%"; else awk -v n=$n -v d=$d 'BEGIN{printf("%.2f%%", (n/d)*100)}'; fi; }

declare -A CASES
for p in "$ROOT"/GraphQLer/* "$ROOT"/EvoMaster/*; do
  [[ -d $p ]] || continue
  CASES["$(basename "$p")"]=1
done

mapfile -t ORDER < <(printf '%s\n' "${!CASES[@]}" | sort)

echo "Case | GraphQLer (+) | GraphQLer (-) | EvoMaster (+) | EvoMaster (-)"
echo "---------------------------------------------------------------"

TGpN=0; TGpD=0; TGnN=0; TGnD=0; TEpN=0; TEpD=0; TEnN=0; TEnD=0

for c in "${ORDER[@]}"; do
  # GraphQLer
  g_pos_n=0; g_pos_d=0; g_neg_n=0; g_neg_d=0
  g_log="$ROOT/GraphQLer/$c/_GraphQLer.log"
  [[ -f $g_log ]] || g_log="$ROOT/GraphQLer/$c/stats.txt"
  if [[ -f $g_log ]]; then
    line_s=$(grep -E "unique query/mutation successes:" "$g_log" | tail -1 || true)
    line_f=$(grep -E "unique external query/mutation failures:" "$g_log" | tail -1 || true)
    [[ $line_s =~ ([0-9]+)/([0-9]+) ]] && g_pos_n=${BASH_REMATCH[1]} && g_pos_d=${BASH_REMATCH[2]}
    [[ $line_f =~ ([0-9]+)/([0-9]+) ]] && g_neg_n=${BASH_REMATCH[1]} && g_neg_d=${BASH_REMATCH[2]}
    [[ $g_pos_d -ne 0 && $g_neg_d -eq 0 ]] && g_neg_d=$g_pos_d
  fi

  # EvoMaster
  e_pos_n=0; e_pos_d=0; e_neg_n=0; e_neg_d=0
  e_log="$ROOT/EvoMaster/$c/_EvoMaster.log"
  if [[ -f $e_log ]]; then
    line_e=$(grep -E "Successfully executed \(no 'errors'\)" "$e_log" | tail -1 || true)
    if [[ $line_e =~ ([0-9]+)[[:space:]]+endpoints[[:space:]]+out[[:space:]]+of[[:space:]]+([0-9]+) ]]; then
      e_pos_n=${BASH_REMATCH[1]}; e_pos_d=${BASH_REMATCH[2]}; e_neg_d=${BASH_REMATCH[2]}
      # Potential faults line
      line_pf=$(grep -E "\* Potential faults:" "$e_log" | tail -1 || true)
      if [[ $line_pf =~ Potential\ faults:\ ([0-9]+) ]]; then
        e_neg_n=${BASH_REMATCH[1]}
      else
        e_neg_n=0
      fi
    fi
  fi

  ((TGpN+=g_pos_n, TGpD+=g_pos_d, TGnN+=g_neg_n, TGnD+=g_neg_d, TEpN+=e_pos_n, TEpD+=e_pos_d, TEnN+=e_neg_n, TEnD+=e_neg_d))

  printf '%s | %d/%d (%s) | %d/%d (%s) | %d/%d (%s) | %d/%d (%s)\n' \
    "$c" \
    $g_pos_n $g_pos_d "$(percent $g_pos_n $g_pos_d)" \
    $g_neg_n $g_neg_d "$(percent $g_neg_n $g_neg_d)" \
    $e_pos_n $e_pos_d "$(percent $e_pos_n $e_pos_d)" \
    $e_neg_n $e_neg_d "$(percent $e_neg_n $e_neg_d)"
done

echo "---------------------------------------------------------------"
printf 'TOTAL | %d/%d (%s) | %d/%d (%s) | %d/%d (%s) | %d/%d (%s)\n' \
  $TGpN $TGpD "$(percent $TGpN $TGpD)" \
  $TGnN $TGnD "$(percent $TGnN $TGnD)" \
  $TEpN $TEpD "$(percent $TEpN $TEpD)" \
  $TEnN $TEnD "$(percent $TEnN $TEnD)"
echo "(0/0 => 100.00%)"
