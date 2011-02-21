class RPageD
  # this is the relationship between page and ds

  include Mongoid::Document

  field :new_d_name
  field :query_hash, :type => Hash

  referenced_in :d
  embedded_in :page
  
  def default_query
    ret = self.d.get_klass
    
    queried = false
    
    self.query_hash.each do |k,v|
    #i know it is not good
      unless v.blank?
        if(k.to_s == "excludes")
          cond = {}
          ar = v.split("=")
          if ar.size > 0
            cond[ar[0].strip] = ar[1].strip
            ret = ret.send(k, cond)
          end
        elsif(k.to_s == "limit")
          ret = ret.send(k, v.to_i)
        else
          ret = ret.send(k, v)
        end
        queried = true
      end
    end

    if queried
      ret
    else
      ret.all
    end
  end
end