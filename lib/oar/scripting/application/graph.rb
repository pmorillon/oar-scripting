# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Wed Feb 29 15:09:48 +0100 2012
#

require 'oar/scripting/application'
require 'fileutils'
require 'rubyvis'
require 'json'

class OAR::Scripting::Application::Graph < OAR::Scripting::Application

  include OAR::Scripting

  CMD_NAME = "oar-scripting-graph"

  option :help,
    :short        => "-h",
    :long         => "--help",
    :description  => "Show this message",
    :on           => :tail,
    :boolean      => true,
    :show_options => true,
    :exit         => 0

  option :version,
    :short        => "-v",
    :long         => "--version",
    :description  => "Show oar-scripting version",
    :boolean      => true,
    :proc         => lambda {|v| puts "#{CMD_NAME}: #{OAR::Scripting::VERSION}"},
    :exit         => 0

  option :output,
    :short        => "-o PATH",
    :long         => "--output PATH",
    :description  => "Output directory",
    :default      => Config[:output]

  def initialize
    super
  end # def:: initialize

  def run_application
    Config[:timeout] = 120
    raise "Directory does not exist : #{config[:output]}" until File.exist?(config[:output])
    FileUtils.rm_rf File.join(config[:output], "oar-scripting-graph") if File.exist?(File.join(config[:output], "oar-scripting-graph"))
    FileUtils.mkdir File.join(config[:output], "oar-scripting-graph")
    FileUtils.mkdir File.join(config[:output], "oar-scripting-graph", "css")
    FileUtils.mkdir File.join(config[:output], "oar-scripting-graph", "js")
    FileUtils.mkdir File.join(config[:output], "oar-scripting-graph", "images")
    FileUtils.mkdir File.join(config[:output], "oar-scripting-graph", "logs")
    FileUtils.cp(File.join(File.dirname(__FILE__), 'graph', 'sh_emacs.css'),File.join(config[:output], "oar-scripting-graph", "css"))
    FileUtils.cp(File.join(File.dirname(__FILE__), 'graph', 'sh_main.min.js'),File.join(config[:output], "oar-scripting-graph", "js"))
    FileUtils.cp(File.join(File.dirname(__FILE__), 'graph', 'sh_ruby.min.js'),File.join(config[:output], "oar-scripting-graph", "js"))

    html_path = File.join(config[:output], "oar-scripting-graph")

    dataset = {}

    %w{prologue epilogue}.each do |script|
      dataset[script.to_sym] = {}
      Dir["/var/log/oar/*-#{script}-*.log"].each do |file|
        log = File.read(file).scan(/^.*\[stats\].*$/).first
        log.nil? ? next : json = log.gsub(/^.*\[stats\](.*)$/, '\1')
        stats = JSON.parse json
        p stats
        dataset[script.to_sym][:global] ||= []
        dataset[script.to_sym][:global] << OpenStruct.new( {"x" => stats["job"]["resources_count"], "y" => stats["job"]["host_count"], "z" => stats["duration"]} )
        dataset[script.to_sym][:steps_list] ||= []
        stats["steps"].each do |step|
          dataset[script.to_sym][:steps_list] << step["name"] if !dataset[script.to_sym][:steps_list].include?(step["name"])
          dataset[script.to_sym][:steps] ||= {}
          dataset[script.to_sym][:steps][step["name"].to_sym] ||= []
          dataset[script.to_sym][:steps][step["name"].to_sym] << OpenStruct.new( {"x" => stats["job"]["resources_count"], "y" => stats["job"]["host_count"], "z" => step["duration"]} )
        end
      end
    end

    dataset.each do |script,datas|
      graph_gen("#{script.to_s.capitalize} duration (all steps)", File.join(html_path, "images", "#{script.to_s}_all.svg"), dataset[script][:global])
      dataset[script][:steps_list].each do |step|
        graph_gen("#{script.to_s.capitalize} duration (#{step})", File.join(html_path, "images", "#{script.to_s}_#{step}.svg"), dataset[script][:steps][step.to_sym])
      end
    end

    open(File.join(html_path, "index.html"), "w") do |file|
      file.puts <<-EOH
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    <html>
      <head>
        <title>OAR Scripting graph</title>
      <link rel="stylesheet" title="Default" href="./css/sh_emacs.css">
      <script type="text/javascript" src="./js/sh_main.min.js"></script>
      <script type="text/javascript" src="./js/sh_ruby.min.js"></script>
      </head>
    EOH
      file.puts <<-EOH
      <body onload="sh_highlightDocument('js/', 'sh_ruby.min.js');">
        <h1>OAR Scripting graph</h1>
        <h3>PROLOGUE_EPILOGUE_TIMEOUT=#{Config[:timeout]}</h3>
        <h4>Generated at #{Time.now}</h4>
    EOH
      dataset.each do |script,datas|
        file.puts "<div>"
        file.puts "<pre class=\"sh_ruby\">"
        file.puts File.read("/etc/oar/#{script.to_s}")
        file.puts <<-EOH
        </pre>
        </div>
        <div class='image'>
          <!--[if IE]>
            <embed class='svg' height='600' src='#{File.join("./images", "#{script.to_s}_all.svg")}' width='1100'></embed>
          <![endif]-->
          <object class='svg' data='#{File.join("./images", "#{script.to_s}_all.svg")}' height='600' type='image/svg+xml' width='1100'></object>
        </div>
    EOH
        dataset[script][:steps_list].each do |step|
          file.puts <<-EOH
        <div class='image'>
          <!--[if IE]>
            <embed class='svg' height='600' src='#{File.join("./images", "#{script.to_s}_#{step}.svg")}' width='1100'></embed>
          <![endif]-->
          <object class='svg' data='#{File.join("./images", "#{script.to_s}_#{step}.svg")}' height='600' type='image/svg+xml' width='1100'></object>
        </div>
    EOH
        end
      end
      file.puts <<-EOH
      </body>
    </html>
    EOH
    end
  end # def:: run_application

  def graph_gen(title, file_path, data)

    x_max = 0
    y_max = 0
    data.each do |entry|
      x_max = entry.x if entry.x > x_max
      y_max = entry.y if entry.y > y_max
    end

    axis = {  :x => { :title => "Recources count", :max => x_max },
              :y => { :title => "Nodes count", :max => y_max } }

    panel = { :title  => title,
              :bottom => 60,
              :left   => 60,
              :right  => 40,
              :top    => 40 }

    w = 1000
    h = 400

    timeout = Config[:timeout]

    x = pv.Scale.linear(0, axis[:x][:max]).range(0, w)
    y = pv.Scale.linear(0, axis[:y][:max]).range(0, h)

    c = pv.Scale.log(1, timeout).range("green", "brown")

    # The root panel.
    vis = pv.Panel.new().width(w).height(h).bottom(panel[:bottom]).left(panel[:left]).right(panel[:right]).top(panel[:top])

    # Main title
    vis.add(pv.Label).left(((w + panel[:left] + panel[:right]) - panel[:title].length) / 2 ).bottom(h).textAngle(0).text(panel[:title]).font( "35" + "px sans-serif")

    # Axis titles
    vis.add(pv.Label).left(-20).bottom(h/2 - (axis[:y][:title].length / 2)).textAngle(-Math::PI/2).text(axis[:y][:title]).font( "20" + "px sans-serif")
    vis.add(pv.Label).left(w/2 - (axis[:x][:title].length / 2)).bottom(-40).textAngle(0).text(axis[:x][:title]).font( "20" + "px sans-serif")

    # Y-axis and ticks.
    vis.add(pv.Rule).data(y.ticks()).bottom(y).strokeStyle(lambda {|d| d!=0 ? "#eee" : "#000"}).anchor("left").add(pv.Label).visible(lambda {|d|  d > 0 and d < axis[:y][:max]}).text(y.tick_format)

    # X-axis and ticks.
    vis.add(pv.Rule).data(x.ticks()).left(x).stroke_style(lambda {|d| d!=0 ? "#eee" : "#000"}).anchor("bottom").add(pv.Label).visible(lambda {|d|  d > 0 and d < axis[:x][:max]}).text(x.tick_format)

    #/* The dot plot! */
    vis.add(pv.Panel).data(data).add(pv.Dot).left(lambda {|d| x.scale(d.x)}).bottom(lambda {|d| y.scale(d.y)}).stroke_style(lambda {|d| c.scale(d.z)}).fill_style(lambda {|d| c.scale(d.z).alpha(0.2)}).shape_size(lambda {|d| d.z * 5}).anchor("center").add(pv.Label).visible(lambda {|d| d.z > 30}).textAngle(0).text(lambda {|d| "%0.1f" %  d.z});

    vis.render()

    open(file_path, "w") do |file|
      file.puts vis.to_svg
    end

  end # def:: graph_gen(title, file_path)


end # class:: OAR::Scripting::Application::Graph < OAR::Scripting::Application
