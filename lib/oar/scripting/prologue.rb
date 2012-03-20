# Author:: Pascal Morillon (<pascal.morillon@irisa.fr>)
# Date:: Thu Feb 23 16:43:39 +0100 2012
#

require 'oar/scripting/script'

class OAR::Scripting::Prologue < OAR::Scripting::Script

  def initialize
    @@type = :prologue
    super
  end # def:: initialize

end # class:: OAR::Scripting::Prologue < OAR::Scripting::Script

