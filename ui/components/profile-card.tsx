"use client"

import Image from "next/image"
import { MapPin, Award } from "lucide-react"

interface ProfileCardProps {
  username: string
  avatar: string
  rank: string
  location: string
  tripsCompleted: number
  routesSaved: number
}

export function ProfileCard({
  username,
  avatar,
  rank,
  location,
  tripsCompleted,
  routesSaved,
}: ProfileCardProps) {
  return (
    <div className="bg-card rounded-xl p-4 shadow-sm border border-border">
      <div className="flex items-center gap-4">
        <div className="relative w-16 h-16 rounded-full overflow-hidden ring-2 ring-primary/20">
          <Image
            src={avatar}
            alt={username}
            fill
            className="object-cover"
          />
        </div>
        <div className="flex-1 min-w-0">
          <h2 className="font-semibold text-lg text-card-foreground truncate">
            {username}
          </h2>
          <div className="flex items-center gap-1.5 text-muted-foreground text-sm">
            <MapPin className="w-3.5 h-3.5" />
            <span>{location}</span>
          </div>
          <div className="flex items-center gap-1.5 mt-1">
            <Award className="w-4 h-4 text-accent" />
            <span className="text-sm font-medium text-accent">{rank}</span>
          </div>
        </div>
      </div>
      <div className="flex items-center gap-4 mt-4 pt-4 border-t border-border">
        <div className="flex-1 text-center">
          <p className="text-2xl font-bold text-card-foreground">{tripsCompleted}</p>
          <p className="text-xs text-muted-foreground">Trips Completed</p>
        </div>
        <div className="w-px h-10 bg-border" />
        <div className="flex-1 text-center">
          <p className="text-2xl font-bold text-card-foreground">{routesSaved}</p>
          <p className="text-xs text-muted-foreground">Routes Saved</p>
        </div>
      </div>
    </div>
  )
}
