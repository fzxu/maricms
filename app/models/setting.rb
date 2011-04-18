##
# MariCMS
# Copyright 2011 金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
# http://www.maricms.com

# This file is part of MariCMS, an open source content management system.

# MariGold MariCMS is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
# 
# Under the terms of the GNU Affero General Public License you must release the
# complete source code for any application that uses any part of MariCMS
# (system header files and libraries used by the operating system are excluded).
# These terms must be included in any work that has MariCMS components.
# If you are developing and distributing open source applications under the
# GNU Affero General Public License, then you are free to use MariCMS.
# 
# If you are deploying a web site in which users interact with any portion of
# MariCMS over a network, the complete source code changes must be made
# available.  For example, include a link to the source archive directly from
# your web site.
# 
# For OEMs, ISVs, SIs and VARs who distribute MariCMS with their products,
# and do not license and distribute their source code under the GNU
# Affero General Public License, MariGold provides a flexible commercial
# license.
# 
# To anyone in doubt, we recommend the commercial license. Our commercial license
# is competitively priced and will eliminate any confusion about how
# MariCMS can be used and distributed.
# 
# MariCMS is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with MariCMS.  If not, see <http://www.gnu.org/licenses/>.
# 
# Attribution Notice: MariCMS is an Original Work of software created
# by  金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
##

class Setting
  include Mongoid::Document

	field :application_title, :type => String
  field :current_theme, :type => String
	field :date_format, :type => String
	field :time_format, :type => String
	field :attachment_max_size, :type => Integer
	field :host_name, :type => String
	field :ruby_bin_path, :type => String
	field :gem_bin_path, :type => String
	field :repo_path, :type => String
	field :repo_user, :type => String
	field :repo_group, :type => String
	
	field :languages, :type => Array  #The languages that the sites currently supports
	field :default_lang, :type => String
	field :use_client_locale, :type => Boolean
	
	def default_language
	  self.default_lang.gsub(/-/, '_')
	end
	
	def to_liquid
    {
      "app_title" => self.application_title,
      "current_theme" => self.current_theme,
      "host_name" => self.host_name,
      "languages" => self.languages,
      "default_lang" => self.default_lang
    }
	end
end
