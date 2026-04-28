"use client"

import { Search, SlidersHorizontal } from "lucide-react"
import { useState } from "react"

interface SearchBarProps {
  onSearch?: (query: string) => void
  onFilterClick?: () => void
}

export function SearchBar({ onSearch, onFilterClick }: SearchBarProps) {
  const [query, setQuery] = useState("")

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSearch?.(query)
  }

  return (
    <form onSubmit={handleSubmit} className="relative">
      <div className="flex items-center gap-2 bg-card border border-border rounded-xl px-4 py-3 shadow-sm focus-within:ring-2 focus-within:ring-primary/20 transition-all">
        <Search className="w-5 h-5 text-muted-foreground flex-shrink-0" />
        <input
          type="text"
          placeholder="Search destinations, routes..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          className="flex-1 bg-transparent text-card-foreground placeholder:text-muted-foreground focus:outline-none text-sm"
        />
        <button
          type="button"
          onClick={onFilterClick}
          className="flex items-center justify-center w-9 h-9 -mr-1 rounded-lg bg-secondary hover:bg-secondary/80 text-secondary-foreground transition-colors"
          aria-label="Open filters"
        >
          <SlidersHorizontal className="w-4.5 h-4.5" />
        </button>
      </div>
    </form>
  )
}
