module PrintHelper
  def buildings
    $buildings.sort
  end
  
  def choose_building
    @print.building.presence || flash[:building].presence
  end
  
  def choose_printer
    @print.printer.presence || flash[:printer].presence
  end
  
  def default_printers
    building = choose_building || buildings.first
    $printers[building]
  end
  def all_printers
    printers = []
    buildings.each do |building|
      printers.concat $printers[building]      
    end
    printers.sort
  end
end