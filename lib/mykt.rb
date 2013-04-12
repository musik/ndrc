#require 'anemone/storage/kyoto_cabinet'
#class Mykt < Anemone::Storage::KyotoCabinet 
  #def initialize(file)
    #raise "KyotoCabinet filename must have .kch extension" if File.extname(file) != '.kch'
    #@db = ::KyotoCabinet::DB::new
    #@db.open(file, ::KyotoCabinet::DB::OWRITER | ::KyotoCabinet::DB::OCREATE)
  #end  
#end
