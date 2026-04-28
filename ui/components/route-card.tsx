"use client"

import Image from "next/image"
import { Heart, MessageCircle, Bookmark, BookmarkCheck } from "lucide-react"
import { useState } from "react"

interface RouteCardProps {
  id: string
  image: string
  title: string
  description: string
  budget: string
  creator: string
  creatorAvatar: string
  likes: number
  comments: number
  saves: number
  isSaved?: boolean
  isLiked?: boolean
  onToggleSave?: (id: string) => void
  onToggleLike?: (id: string) => void
}

export function RouteCard({
  id,
  image,
  title,
  description,
  budget,
  creator,
  creatorAvatar,
  likes,
  comments,
  saves,
  isSaved = false,
  isLiked = false,
  onToggleSave,
  onToggleLike,
}: RouteCardProps) {
  const [localLikes, setLocalLikes] = useState(likes)
  const [localSaves, setLocalSaves] = useState(saves)
  const [localIsLiked, setLocalIsLiked] = useState(isLiked)
  const [localIsSaved, setLocalIsSaved] = useState(isSaved)

  const handleLike = () => {
    setLocalIsLiked(!localIsLiked)
    setLocalLikes(localIsLiked ? localLikes - 1 : localLikes + 1)
    onToggleLike?.(id)
  }

  const handleSave = () => {
    setLocalIsSaved(!localIsSaved)
    setLocalSaves(localIsSaved ? localSaves - 1 : localSaves + 1)
    onToggleSave?.(id)
  }

  return (
    <article className="bg-card rounded-xl overflow-hidden shadow-sm border border-border transition-all hover:shadow-md">
      <div className="relative h-48 w-full">
        <Image
          src={image}
          alt={title}
          fill
          className="object-cover"
        />
        <div className="absolute top-3 right-3 bg-primary/90 backdrop-blur-sm text-primary-foreground text-xs font-semibold px-3 py-1.5 rounded-full">
          {budget}
        </div>
      </div>
      <div className="p-4">
        <h3 className="font-semibold text-lg text-card-foreground leading-tight mb-1.5">
          {title}
        </h3>
        <p className="text-muted-foreground text-sm leading-relaxed line-clamp-2 mb-3">
          {description}
        </p>
        <div className="flex items-center gap-2 mb-4">
          <div className="relative w-6 h-6 rounded-full overflow-hidden">
            <Image
              src={creatorAvatar}
              alt={creator}
              fill
              className="object-cover"
            />
          </div>
          <span className="text-sm text-muted-foreground">by <span className="text-card-foreground font-medium">{creator}</span></span>
        </div>
        <div className="flex items-center justify-between pt-3 border-t border-border">
          <div className="flex items-center gap-4">
            <button 
              onClick={handleLike}
              className="flex items-center gap-1.5 text-muted-foreground hover:text-destructive transition-colors group"
              aria-label={localIsLiked ? "Unlike route" : "Like route"}
            >
              <Heart 
                className={`w-5 h-5 transition-all ${localIsLiked ? "fill-destructive text-destructive scale-110" : "group-hover:scale-110"}`} 
              />
              <span className="text-sm font-medium">{localLikes}</span>
            </button>
            <button 
              className="flex items-center gap-1.5 text-muted-foreground hover:text-primary transition-colors group"
              aria-label="View comments"
            >
              <MessageCircle className="w-5 h-5 group-hover:scale-110 transition-transform" />
              <span className="text-sm font-medium">{comments}</span>
            </button>
          </div>
          <button 
            onClick={handleSave}
            className="flex items-center gap-1.5 text-muted-foreground hover:text-primary transition-colors group"
            aria-label={localIsSaved ? "Remove from saved" : "Save route"}
          >
            {localIsSaved ? (
              <BookmarkCheck className="w-5 h-5 fill-primary text-primary scale-110" />
            ) : (
              <Bookmark className="w-5 h-5 group-hover:scale-110 transition-transform" />
            )}
            <span className="text-sm font-medium">{localSaves}</span>
          </button>
        </div>
      </div>
    </article>
  )
}
