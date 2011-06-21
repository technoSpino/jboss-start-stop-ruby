#!/usr/bin/env ruby


#########################################
#####				     ####	
#####	Start and Stopping JBoss     ####	
#####				     ####	
#########################################
@system       = nil
@jboss_home   = ENV['JBOSS_HOME']     
@method       = ARGV[0]
@instance_name= ARGV[1]
@ip           = ARGV[2]
@ports_binding= ARGV[3]
@jmx_user     = ARGV[4]
@jmx_password = ARGV[5]
@jndi_port    = 1099







#########################################
#####				     ####	
#####	     Helper Methods          ####	
#####				     ####	
#########################################


def check_OS()
  puts ENV['OS'] 
  if ENV['OS'] == "Windows_NT"
    @system = :windows
    return
  end

  if ENV['OS'] == nil
    @system = :linux
    return 
  end
end

def is_jboss_running?
  if @system == :windows
    result = `#{@jboss_home}\\bin\\twiddle.bat -s #{@ip}:#{@jndi_port} -u #{@jmx_user} -p #{@jmx_password} get "jboss.system:type=Server" Started`
  end
  if @system == :linux  
    result = `#{@jboss_home}/bin/twiddle.sh -s #{@ip}:#{@jndi_port} -u #{@jmx_user} -p #{@jmx_password} get "jboss.system:type=Server" Started`
  end
  if result.scan(/\bReceive timed out\b/).length >= 1
    return false
  end
  true
end

def start_the_boss
  status=""
  if is_jboss_running?
    puts "      JBoss is already running!"
  else
    puts "      Starting up!"
    if @system == :linux
      `#{@jboss_home}bin/run.sh -c #{@instance_name} -b #{@ip} -Djboss.service.binding.set=#{@ports_binding} >> #{@jboss_home}bin/start_stop.log& `
      
      while status.strip != "Started=true"
        status = `#{@jboss_home}/bin/twiddle.sh -s #{@ip}:#{@jndi_port} -u #{@jmx_user} -p #{@jmx_password} get "jboss.system:type=Server" Started`	
	puts "Server is still warming up"
	sleep 5 
      end
    puts "       The Boss is playing!!"
    end
    if @system == :windows
      
	  `start #{@jboss_home}bin\\run.vbs #{@instance_name} #{@ip} #{@ports_binding} `
      puts "test"
	  while status.strip != "Started=true"
        status = `#{@jboss_home}\\bin\\twiddle.bat -s #{@ip}:#{@jndi_port} -u #{@jmx_user} -p #{@jmx_password} get "jboss.system:type=Server" Started`	
	    puts "Server is still warming up"
	    sleep 5 
      end
    end
  end 
end

def stop_the_boss
  if is_jboss_running?
    puts "Stopping the Boss"
    if @system == :linux
      `#{@jboss_home}bin/shutdown.sh -u #{@jmx_user} -p #{@jmx_password} --server=#{@ip}:#{@jndi_port}  >> #{@jboss_home}bin/start_stop.log& `
      puts "The Boss is done!!"
    end
    if @system == :windows
      ` start #{@jboss_home}\\bin\\shutdown.bat -u #{@jmx_user} -p #{@jmx_password} --server=#{@ip}:#{@jndi_port}  >> #{@jboss_home}\\bin\\start_stop.log `
	  puts "The Boss is done!!"
    end
  end
end

def print_help
    puts
    puts "      Usage start_stop.rb {start|stop} INSTANCE_NAME IP PORTS_BINDING JGROUP JMX_USER JMX_PASSWORD"
    puts
end

def check_usage
  if ARGV.length < 6
    print_help
    exit
  end
end

def calculate_jndi_port
  if @ports_binding != "ports-default"
    jndi_offset  = Integer(@ports_binding.delete "ports-") * 100
    @jndi_port += jndi_offset
  end   
end
	


#########################################
#####				     ####	
#####	    Executable Process       ####	
#####				     ####	
#########################################


check_OS
check_usage
calculate_jndi_port
if    @method == "start"
  start_the_boss
  exit
elsif @method == "stop"
  stop_the_boss
  exit
else
  print_help 
end
