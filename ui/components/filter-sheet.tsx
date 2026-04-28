"use client"

import { X } from "lucide-react"
import { useState } from "react"

interface FilterSheetProps {
  isOpen: boolean
  onClose: () => void
  onApply?: (filters: FilterState) => void
}

interface FilterState {
  region: string
  budget: string
  activity: string[]
}

const regions = ["All Regions", "Europe", "Asia", "Africa", "Americas", "Oceania"]
const budgets = ["Any Budget", "Budget ($0-$500)", "Mid-Range ($500-$2000)", "Luxury ($2000+)"]
const activities = ["Adventure", "Cultural", "Beach", "City", "Nature", "Food & Wine", "Wellness"]

export function FilterSheet({ isOpen, onClose, onApply }: FilterSheetProps) {
  const [filters, setFilters] = useState<FilterState>({
    region: "All Regions",
    budget: "Any Budget",
    activity: [],
  })

  const toggleActivity = (activity: string) => {
    setFilters((prev) => ({
      ...prev,
      activity: prev.activity.includes(activity)
        ? prev.activity.filter((a) => a !== activity)
        : [...prev.activity, activity],
    }))
  }

  const handleApply = () => {
    onApply?.(filters)
    onClose()
  }

  const handleReset = () => {
    setFilters({
      region: "All Regions",
      budget: "Any Budget",
      activity: [],
    })
  }

  if (!isOpen) return null

  return (
    <>
      <div 
        className="fixed inset-0 bg-background/80 backdrop-blur-sm z-40"
        onClick={onClose}
      />
      <div className="fixed inset-x-0 bottom-0 z-50 bg-card rounded-t-2xl shadow-xl border-t border-border max-h-[85vh] overflow-y-auto">
        <div className="sticky top-0 bg-card px-4 pt-4 pb-2 border-b border-border">
          <div className="flex items-center justify-between">
            <h2 className="text-lg font-semibold text-card-foreground">Filters</h2>
            <button 
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-secondary transition-colors"
              aria-label="Close filters"
            >
              <X className="w-5 h-5 text-muted-foreground" />
            </button>
          </div>
        </div>
        
        <div className="p-4 space-y-6">
          <div>
            <h3 className="text-sm font-medium text-card-foreground mb-3">Region</h3>
            <div className="flex flex-wrap gap-2">
              {regions.map((region) => (
                <button
                  key={region}
                  onClick={() => setFilters((prev) => ({ ...prev, region }))}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                    filters.region === region
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                  }`}
                >
                  {region}
                </button>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-sm font-medium text-card-foreground mb-3">Budget</h3>
            <div className="flex flex-wrap gap-2">
              {budgets.map((budget) => (
                <button
                  key={budget}
                  onClick={() => setFilters((prev) => ({ ...prev, budget }))}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                    filters.budget === budget
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                  }`}
                >
                  {budget}
                </button>
              ))}
            </div>
          </div>

          <div>
            <h3 className="text-sm font-medium text-card-foreground mb-3">Activities</h3>
            <div className="flex flex-wrap gap-2">
              {activities.map((activity) => (
                <button
                  key={activity}
                  onClick={() => toggleActivity(activity)}
                  className={`px-4 py-2 rounded-full text-sm font-medium transition-colors ${
                    filters.activity.includes(activity)
                      ? "bg-primary text-primary-foreground"
                      : "bg-secondary text-secondary-foreground hover:bg-secondary/80"
                  }`}
                >
                  {activity}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="sticky bottom-0 bg-card px-4 py-4 border-t border-border flex gap-3">
          <button
            onClick={handleReset}
            className="flex-1 py-3 rounded-xl text-sm font-medium bg-secondary text-secondary-foreground hover:bg-secondary/80 transition-colors"
          >
            Reset
          </button>
          <button
            onClick={handleApply}
            className="flex-1 py-3 rounded-xl text-sm font-medium bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
          >
            Apply Filters
          </button>
        </div>
      </div>
    </>
  )
}
