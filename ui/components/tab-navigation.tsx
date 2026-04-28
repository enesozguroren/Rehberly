"use client"

import { Compass, Bookmark, User } from "lucide-react"

type Tab = "discover" | "saved" | "profile"

interface TabNavigationProps {
  activeTab: Tab
  onTabChange: (tab: Tab) => void
}

export function TabNavigation({ activeTab, onTabChange }: TabNavigationProps) {
  const tabs = [
    { id: "discover" as Tab, label: "Discover", icon: Compass },
    { id: "saved" as Tab, label: "Saved", icon: Bookmark },
    { id: "profile" as Tab, label: "Profile", icon: User },
  ]

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-card/95 backdrop-blur-md border-t border-border z-30">
      <div className="max-w-md mx-auto px-4">
        <ul className="flex items-center justify-around">
          {tabs.map((tab) => {
            const Icon = tab.icon
            const isActive = activeTab === tab.id
            return (
              <li key={tab.id}>
                <button
                  onClick={() => onTabChange(tab.id)}
                  className={`flex flex-col items-center gap-1 py-3 px-6 transition-colors ${
                    isActive
                      ? "text-primary"
                      : "text-muted-foreground hover:text-card-foreground"
                  }`}
                  aria-current={isActive ? "page" : undefined}
                >
                  <Icon className={`w-5 h-5 ${isActive ? "stroke-[2.5px]" : ""}`} />
                  <span className={`text-xs ${isActive ? "font-semibold" : "font-medium"}`}>
                    {tab.label}
                  </span>
                </button>
              </li>
            )
          })}
        </ul>
      </div>
      <div className="h-safe-area-inset-bottom bg-card" />
    </nav>
  )
}
