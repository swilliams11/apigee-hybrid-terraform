import re
import yaml

# This file was supposed to be a simplified overrides.yaml file but I decided not to use this.  
# The user should make sure to update the overrides.yaml file directly instead.
key_value_config_file_name = 'overrides_keys_values.yaml'
overrides_file_name = 'overrides.yaml'

with open(key_value_config_file_name, 'r') as file:
   with open(overrides_file_name, 'w+') as overrides_file:
      values = yaml.safe_load(file)
      overrides = yaml.safe_load(overrides_file)
      for key, value in values.items():
         overrides[]
         

# def case_insensitive_search_and_replace(file_path, search_word, replace_word):
#    with open(file_path, 'r') as file:
#       file_contents = file.read()

#       pattern = re.compile(re.escape(search_word), re.IGNORECASE)
#       updated_contents = pattern.sub(replace_word, file_contents)

#    with open(file_path, 'w') as file:
#       file.write(updated_contents)