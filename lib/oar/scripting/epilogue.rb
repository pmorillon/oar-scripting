# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Thu Feb 23 16:43:48 +0100 2012
#

require 'oar/scripting/script'

class OAR::Scripting::Epilogue < OAR::Scripting::Script

  def initialize
    @@type = :epilogue
    super
  end # def:: initialize

end # class:: OAR::Scripting::Epilogue < OAR::Scripting::Script

