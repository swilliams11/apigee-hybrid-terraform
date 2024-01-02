import re


list

def case_insensitive_search_and_replace(file_path, search_word, replace_word):
   with open(file_path, 'r') as file:
      file_contents = file.read()

      pattern = re.compile(re.escape(search_word), re.IGNORECASE)
      updated_contents = pattern.sub(replace_word, file_contents)

   with open(file_path, 'w') as file:
      file.write(updated_contents)