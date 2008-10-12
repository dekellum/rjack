
module SLF4J
  # SLF4J-java version
  SLF4J_VERSION = '1.5.3'
  # SLF4J gem version
  VERSION = SLF4J_VERSION + '.1'

  SLF4J_DIR = File.dirname(__FILE__) # :nodoc:


  #              :input              :output (jar with slf4j- prefix)
  ADAPTERS = [ [ "jul-to-slf4j",     "jdk14"   ],   
               [ "jcl-over-slf4j",   "jcl"     ],
               [ "log4j-over-slf4j", "log4j12" ],
               [ nil,                "nop"     ],
               [ nil,                "simple"  ] ] # :nodoc:
      
end
