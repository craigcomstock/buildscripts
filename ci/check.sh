# Find all shell scripts ending in .sh (regardless of if they have a shebang or not (like packaging scriptlets
find -name '*.sh' | while read -r file; do
  shellcheck --external-sources "$file"
done

# Recursively find all shell scripts in the build-scripts directory with a shebang
grep -Erl '^(#!/(bin|usr/bin)/(env )?(sh|bash))' build-scripts/ | while read -r file; do
  shellcheck --external-sources --source-path=build-scripts "$file"
done

