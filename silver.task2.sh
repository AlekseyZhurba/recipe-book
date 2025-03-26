#!/bin/bash

# Перевірка аргументів командного рядка
if [ $# -eq 0 ]; then
  echo "enter /path/to/file/name.file AS parameter"
  exit 1
fi

file_name="$1"

# Перевірка на існування файлу
if [ ! -e "$file_name" ]; then
  echo "file $file_name not found or does not exist"
  exit 1
fi

# Читання файлу в масив
pars_data=()
while IFS= read -r line; do
  pars_data+=("$line")
done < "$file_name"

# Ініціалізація рядка JSON
str2json="}"

# Обробка рядків
for ((i = 0; i < ${#pars_data[@]}; i++)); do
  line="${pars_data[$i]}"
  line_next="${pars_data[$i + 1]}"

  # Видалення символів нового рядка
  line_trimmed=$(echo "$line" | tr -d '\n')

  if [[ "$line_trimmed" =~ \[\ ([^]]+)\ \],.* ]]; then
    test_name="${BASH_REMATCH[1]}"
    str2json+="
        \"testName\":\"$test_name\",
        \"tests\":["
  elif [[ "$line_trimmed" =~ ^-{2,}$ ]]; then
    continue
  elif [[ "$line_trimmed" =~ ^(not\ ok|ok)\ +[0-9]+\ +(.*)\,\ ([0-9]+ms)$ ]]; then
    status=$(if [[ "${BASH_REMATCH[1]}" == "ok" ]]; then echo "true"; else echo "false"; fi)
    str2json+="
                {
                        \"name\":\"${BASH_REMATCH[3]}\",
                        \"status\":\"$status\",
                        \"duration\":\"${BASH_REMATCH[4]}\"
                }"
    if [[ "$line_next" =~ ^-{2,}$ ]]; then
      str2json+="
        ],
        "
    else
      str2json+=","
    fi
  elif [[ "$line_trimmed" =~ ([0-9]+)\ \(of\ [0-9]+\)\ tests\ passed,\ ([0-9]+)\ tests\ failed,\ rated\ as\ ([0-9]+(\.[0-9]+)?)%,\ spent\ ([0-9]+ms) ]]; then
    str2json+="
        \"summary\":{
                \"succes\":${BASH_REMATCH[1]},
                \"failed\":${BASH_REMATCH[2]},
                \"rating\":\"${BASH_REMATCH[3]}\",
                \"duration\":\"${BASH_REMATCH[4]}\"
        }
}"
  fi
done

# Запис JSON у файл
echo "$str2json" > "/home/padavan/output.json"
echo "JSON saved to /home/padavan/output.json"
