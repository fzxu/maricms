class RPageD
  # this is the relationship between page and ds

  include Mongoid::Document

  field :new_d_name, :type => String
  field :query_hash, :type => Hash

  belongs_to :d
  embedded_in :page
  
  def default_query
    if self.d.ds_type == "Tree"
      ret = self.d.get_klass.roots
    else
      ret = self.d.get_klass
    end
    
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