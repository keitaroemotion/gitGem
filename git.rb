require 'rubygems'
require 'git'
require 'colorize'

puts "--start--"
#working_dir = "/Users/keisugano/Fabrica/Specto"
working_dir = "/Users/keisugano/Fabrica/Ruby/sample"
g = Git.open(working_dir)
g.index
puts g.dir

def enlist(list, func, res=Array.new)
  list.each do |log|
    res.push func.call(log)
  end
  return res
end

logs       = enlist(g.log,      Proc.new { |log| log  }) # since.. cond
log_hashes = enlist(g.log,      Proc.new { |log| log.sha  })
local_branches   = enlist(g.branches.local,  Proc.new { |log| log  })
remote_branches  = enlist(g.branches.remote, Proc.new { |log| log  })

def dispCommitList(logs)
  i = 0
  logs.each do |log|
    print "#{i}) "
    print log.sha[0..7].green
    print " "
    puts log.message.red
    i = i + 1
  end
end

def isPlus(d)
  return d.start_with? "+"
end
def isMinus(d)
  return d.start_with? "-"
end
def isNone(d)
  return !(d.start_with? "+") || (d.start_with?("-"))
end
def showPlus(d)
  if isPlus(d)
    puts d.green
  end
  d
end

def showMinus(d)
  if isMinus(d)
    puts d.red
  end
  d
end

def showElse(d)
  if isNone(d)
    puts d
  end
  d
end

def dispDiff(diff) 
  diff.each do |d|
    showPlus(showMinus(showElse(d)))
  end
end

def extractTargetDiff(diff, func, arr=Array.new)
  diff.each do |d|
    if (func.call(d))
      arr.push d
    end
  end
  return arr
end


def compareHashes(g, logs)
  dispCommitList(logs)
  print "Select hashes[space separated:]"
  res = $stdin.gets.chomp.strip

  idx1 = logs.size-1
  idx2 = res.to_i 
  if res.include?(" ")  
    resSp = res.split(' ')
    idx1 = resSp[0].to_i
    idx2 = resSp[1].to_i     
  end
  puts 

  if (idx1 == idx2)
    puts "\n\nHashes Same!!!\n\n".red
    return compareHashes(g, logs)
  end

  print "#{logs[idx1].sha[0..7]} ".cyan
  puts "| #{logs[idx1].message} ".magenta
  
  print "#{logs[idx2].sha[0..7]} ".yellow
  puts "| #{logs[idx2].message} ".magenta
  
  diff = g.diff(logs[idx1].sha, logs[idx2].sha)
  return diff.to_s.split("\n")
end

#git diff
puts log_hashes
puts local_branches
puts remote_branches

diff = compareHashes g, logs
dispDiff diff

plus  = extractTargetDiff(diff, Proc.new {|d| isPlus(d) } )
minus = extractTargetDiff(diff, Proc.new {|d| isMinus(d) } )

puts plus.to_s.green
puts minus.to_s.red



