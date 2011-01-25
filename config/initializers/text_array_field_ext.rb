# module ActionView
#   module Helpers
#     module FormHelper
#       def text_array_field(object_name, method, options = {})
#         InstanceTag.new(object_name, method, self, options.delete(:object)).to_array_input_field_tag("text", options)
#       end
#     end
# 
#     class InstanceTag
#       def to_array_input_field_tag(field_type, options = {})
#         tag_text = ""
#         options = options.stringify_keys
#         options["size"] = options["maxlength"] || DEFAULT_FIELD_OPTIONS["size"] unless options.key?("size")
#         options = DEFAULT_FIELD_OPTIONS.merge(options)
#         if field_type == "hidden"
#           options.delete("size")
#         end
#         options["type"]  ||= field_type
# 
#         values = value_before_type_cast(object)
#         array_input_id = options.fetch("id"){ tag_id }
#         values.each_index do |index|
#           options["value"] = ERB::Util.html_escape(values[index])
#           #debugger
#           options["id"] =  array_input_id + "_" + index.to_s
#           options["name"] = tag_name + "[]"
#           tag_text << "<br/>"
#           tag_text << tag("input", options)
#         end
#         tag_text.html_safe
#       end
#     end
# 
#     class FormBuilder
#       def text_array_field(method, options = {})
#         @template.send(
#           "text_array_field",
#           @object_name,
#           method,
#         objectify_options(options))
#       end
#     end
#   end
# end
# 
# module BSON
#   class ObjectId
#     def to_i
#       self.to_s
#     end
#   end
# end
