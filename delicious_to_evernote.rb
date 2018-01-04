# encoding: utf-8
require 'nokogiri'

$in_filename = "delicious.html"
$out_filename = "Evernote.enex"

def main
  content = File.read($in_filename, encoding: "utf-8")
  fragments = content.split("<DT>")

  first_fragment = fragments.shift
  raise "Unexpected first fragment: #{first_fragment}" unless first_fragment.start_with?("<!DOCTYPE")

  builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
    xml.doc.create_internal_subset("en-export", nil, "http://xml.evernote.com/pub/evernote-export2.dtd")
    xml.send('en-export', {
        'export-date':"20160926T000000Z",
        'application': "Evernote/Windows",
        'version': "6.x"
    }) {
      process_fragments(fragments) do |fragment|
        url, add_date, tags, title, comment = fragment
        date = add_date.utc.strftime("%Y%m%dT%H%M%SZ")
        xml.note {
          xml.title title
          unless comment.nil?
            xml.content {
              xml.cdata(encode_content(comment))
            }
          end
          xml.created date
          xml.updated date
          tags.each do |tag|
            xml.tag tag
          end
          xml.send('note-attributes') {
            xml.source 'web.clip'
            xml.send('source-url', url)
          }
        }
      end
    }
  end
  xml = builder.to_xml

  File.write($out_filename, xml, encoding: "utf-8")
  puts "Success!"
end

def process_fragments(fragments)
  fragments.each do |fragment|
    begin
      yield(process_fragment(fragment))
    rescue => ex
      STDERR.puts ex
    end
  end
end

def process_fragment(fragment)
  raise "Fragment doesn't start as expected: #{fragment}" unless fragment.start_with?("<A HREF")
  raise "Fragment doesn't contain </A>" unless fragment.include?("</A>")

  a_dd = fragment.split("</A>")
  raise "a_dd is expected to have 2 elements" unless a_dd.length == 2

  url, add_date, tags, title = parse_a(a_dd[0])
  comment = parse_dd(a_dd[1])
  [url, add_date, tags, title, comment]
end

def parse_a(a)
  match = /<A HREF="(.+)" ADD_DATE="([0-9]+)" .* TAGS="(.*)">(.+)/m.match(a)
  raise "'A' tag has unexpected format: #{a.inspect}" if match.nil?
  url = match[1].strip
  add_date = Time.at(match[2].strip.to_i)
  tags = match[3].strip.split(',').reject(&:empty?).each { |tag| remove_bad_substrings(tag) }
  title = remove_bad_substrings(match[4].strip)
  raise "title is empty: #{a.inspect}" if title.empty?
  [url, add_date, tags, title]
end

def parse_dd(dd)
  return '' if ['', '</DL><p>'].include?(dd.strip)
  match = /<DD>(.+)/m.match(dd)
  raise "'DD' tag has unexpected format: #{dd.inspect}" if match.nil?
  comment = match[1].strip
  match = /(.+)(?:<\/DL><p>.*)/m.match(comment)
  comment = match[1].strip unless match.nil?
  comment
end

def encode_content(comment)
  prefix = '<?xml version="1.0" encoding="utf-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note>'
  en_note = comment.encode(:xml => :text)
  en_note.gsub!("\n", "<br/>")
  en_note = remove_bad_substrings(en_note)
  suffix = '</en-note>'
  "#{prefix}#{en_note}#{suffix}"
end

def remove_bad_substrings(content)
  content.gsub("\u0099", '')
end

if __FILE__ == $0
  main
end
