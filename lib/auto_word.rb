require "auto_word/version"

module AutoWord

  def self.replace_from_json(file_path, json_data)
    zf = Zip::File.new(file_path)
    buffer = Zip::OutputStream.write_buffer do |out|
      zf.entries.each do |e|
        process_entry(e, out, data)
      end
    end
    return buffer
  end

  private

  def self.process_entry(entry, output, data)
    output.put_next_entry(entry.name)
    output.write get_entry_content(entry, data) if entry.ftype != :directory
  end

  def self.get_entry_content(entry, data)
    file_string = entry.get_input_stream.read
    if entry_requires_replacement?(entry)
      file_string[0, 5] == "<?xml" ?
      replace_entry_placeholders_with_data(file_string, data) : replace_with_new_image()
      else
        file_string
      end
  end

  def self.entry_requires_replacement?(entry)
    (entry.ftype != :directory && entry.name == "word/document.xml") || (entry.ftype != :directory && entry.name.include?('.png'))
  end

  def self.replace_entry_placeholders_with_data(file_string, data)
    data.keys.each do |key|
      file_string.gsub!('{{'+key+'}}', data[key])
    end
    file_string.gsub!('{{Date}}', Date.today.to_s)
    file_string
  end

  def self.replace_with_new_image()
    # File.read(path)
  end

end
