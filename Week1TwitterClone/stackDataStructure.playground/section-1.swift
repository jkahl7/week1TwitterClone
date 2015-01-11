// Playground - noun: a place where people can play

import UIKit

// create a class of books?

class Players {
  var name:String
  var position:String
  var rating:Int
  
  init(name:String, position:String, rating:Int) {
    self.name = name
    self.position = position
    self.rating = rating
  }
}

func push(player:Players) {
  teamRoster.append(player)
}

func pop() {
  teamRoster.removeAtIndex((teamRoster.count - 1))
}

func peak(player:Players) {
  
  
  println("Name:\(player.name) Position:\(player.position) Rating:\(player.rating)")
}
  
  
var teamRoster = [Players]()


let leBron = Players(name: "LeBron", position: "SF", rating: 99)
let johnWall = Players(name: "John Wall", position: "PG", rating: 90)
let carmello = Players(name: "Carmello Anthony", position: "SF", rating: 92)
let noah = Players(name: "Joakim Noah", position: "C", rating: 90)
let butler = Players(name: "Jimmy Butler", position: "SG", rating: 87)


push(leBron)
push(johnWall)
push(butler)
push(noah)
push(carmello)

teamRoster

peak(leBron)
pop()


teamRoster
pop()
pop()
pop()
teamRoster


