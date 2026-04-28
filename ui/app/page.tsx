"use client"

import { useState, useMemo } from "react"
import { RouteCard } from "@/components/route-card"
import { ProfileCard } from "@/components/profile-card"
import { SearchBar } from "@/components/search-bar"
import { FilterSheet } from "@/components/filter-sheet"
import { TabNavigation } from "@/components/tab-navigation"
import { Compass, MapPin } from "lucide-react"

const routesData = [
  {
    id: "1",
    image: "/images/aegean-wonders.jpg",
    title: "Ancient Aegean Wonders",
    description: "Explore the stunning coastline of Greece, visiting ancient ruins, pristine beaches, and charming island villages over 10 unforgettable days.",
    budget: "$1,850",
    creator: "Elena Papadopoulos",
    creatorAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop",
    likes: 342,
    comments: 47,
    saves: 128,
    isSaved: true,
    isLiked: false,
  },
  {
    id: "2",
    image: "/images/japan-spring.jpg",
    title: "Japan Cherry Blossom Trail",
    description: "Follow the blooming sakura from Tokyo to Kyoto, experiencing traditional temples, serene gardens, and authentic Japanese culture.",
    budget: "$2,400",
    creator: "Yuki Tanaka",
    creatorAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop",
    likes: 521,
    comments: 89,
    saves: 245,
    isSaved: false,
    isLiked: true,
  },
  {
    id: "3",
    image: "/images/norway-fjords.jpg",
    title: "Norwegian Fjord Adventure",
    description: "Navigate through majestic fjords, chase the northern lights, and discover Viking heritage in this epic Scandinavian journey.",
    budget: "$3,200",
    creator: "Magnus Eriksson",
    creatorAvatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop",
    likes: 287,
    comments: 34,
    saves: 156,
    isSaved: false,
    isLiked: false,
  },
  {
    id: "4",
    image: "/images/morocco-desert.jpg",
    title: "Moroccan Desert Dreams",
    description: "Journey from vibrant Marrakech through the Atlas Mountains to the golden Sahara, camping under countless stars.",
    budget: "$980",
    creator: "Fatima Benali",
    creatorAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop",
    likes: 198,
    comments: 28,
    saves: 92,
    isSaved: true,
    isLiked: true,
  },
  {
    id: "5",
    image: "/images/bali-terraces.jpg",
    title: "Bali Temple & Rice Trail",
    description: "Discover sacred temples, lush rice terraces, and hidden waterfalls while immersing yourself in Balinese spirituality and culture.",
    budget: "$1,250",
    creator: "Wayan Sudiarta",
    creatorAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop",
    likes: 412,
    comments: 56,
    saves: 187,
    isSaved: false,
    isLiked: false,
  },
]

const userProfile = {
  username: "Alex Thompson",
  avatar: "https://images.unsplash.com/photo-1599566150163-29194dcabd36?w=200&h=200&fit=crop",
  rank: "Experienced Traveler",
  location: "San Francisco, CA",
  tripsCompleted: 12,
  routesSaved: 24,
}

export default function TravelDashboard() {
  const [activeTab, setActiveTab] = useState<"discover" | "saved" | "profile">("discover")
  const [isFilterOpen, setIsFilterOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState("")
  const [savedRouteIds, setSavedRouteIds] = useState<Set<string>>(
    new Set(routesData.filter(r => r.isSaved).map(r => r.id))
  )

  const toggleSave = (id: string) => {
    setSavedRouteIds((prev) => {
      const newSet = new Set(prev)
      if (newSet.has(id)) {
        newSet.delete(id)
      } else {
        newSet.add(id)
      }
      return newSet
    })
  }

  const filteredRoutes = useMemo(() => {
    let routes = routesData
    if (searchQuery) {
      const query = searchQuery.toLowerCase()
      routes = routes.filter(
        (route) =>
          route.title.toLowerCase().includes(query) ||
          route.description.toLowerCase().includes(query) ||
          route.creator.toLowerCase().includes(query)
      )
    }
    return routes
  }, [searchQuery])

  const savedRoutes = useMemo(() => {
    return routesData.filter((route) => savedRouteIds.has(route.id))
  }, [savedRouteIds])

  return (
    <div className="min-h-screen bg-background pb-20">
      {/* Header */}
      <header className="sticky top-0 z-20 bg-background/95 backdrop-blur-md border-b border-border">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <div className="w-9 h-9 rounded-xl bg-primary flex items-center justify-center">
                <Compass className="w-5 h-5 text-primary-foreground" />
              </div>
              <h1 className="text-xl font-bold text-foreground">Wanderly</h1>
            </div>
            <button className="w-9 h-9 rounded-full bg-secondary flex items-center justify-center hover:bg-secondary/80 transition-colors">
              <MapPin className="w-4.5 h-4.5 text-secondary-foreground" />
            </button>
          </div>
          <SearchBar 
            onSearch={setSearchQuery} 
            onFilterClick={() => setIsFilterOpen(true)} 
          />
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-md mx-auto px-4 py-5">
        {activeTab === "discover" && (
          <>
            <ProfileCard {...userProfile} />
            
            <section className="mt-6">
              <div className="flex items-center justify-between mb-4">
                <h2 className="text-lg font-semibold text-foreground">
                  Discover Routes
                </h2>
                <span className="text-sm text-muted-foreground">
                  {filteredRoutes.length} routes
                </span>
              </div>
              <div className="space-y-4">
                {filteredRoutes.map((route) => (
                  <RouteCard
                    key={route.id}
                    {...route}
                    isSaved={savedRouteIds.has(route.id)}
                    onToggleSave={toggleSave}
                  />
                ))}
              </div>
              {filteredRoutes.length === 0 && (
                <div className="text-center py-12">
                  <p className="text-muted-foreground">No routes found matching your search.</p>
                </div>
              )}
            </section>
          </>
        )}

        {activeTab === "saved" && (
          <section>
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold text-foreground">
                Saved Routes
              </h2>
              <span className="text-sm text-muted-foreground">
                {savedRoutes.length} saved
              </span>
            </div>
            {savedRoutes.length > 0 ? (
              <div className="space-y-4">
                {savedRoutes.map((route) => (
                  <RouteCard
                    key={route.id}
                    {...route}
                    isSaved={true}
                    onToggleSave={toggleSave}
                  />
                ))}
              </div>
            ) : (
              <div className="text-center py-12 bg-card rounded-xl border border-border">
                <div className="w-16 h-16 rounded-full bg-secondary flex items-center justify-center mx-auto mb-4">
                  <MapPin className="w-8 h-8 text-muted-foreground" />
                </div>
                <h3 className="text-lg font-semibold text-card-foreground mb-2">No saved routes yet</h3>
                <p className="text-sm text-muted-foreground max-w-xs mx-auto">
                  Start exploring and save routes that inspire your next adventure.
                </p>
              </div>
            )}
          </section>
        )}

        {activeTab === "profile" && (
          <section className="space-y-4">
            <ProfileCard {...userProfile} />
            
            <div className="bg-card rounded-xl p-4 border border-border">
              <h3 className="font-semibold text-card-foreground mb-4">Quick Stats</h3>
              <div className="grid grid-cols-2 gap-3">
                <div className="bg-secondary rounded-lg p-3 text-center">
                  <p className="text-2xl font-bold text-primary">24</p>
                  <p className="text-xs text-muted-foreground">Countries Visited</p>
                </div>
                <div className="bg-secondary rounded-lg p-3 text-center">
                  <p className="text-2xl font-bold text-primary">156</p>
                  <p className="text-xs text-muted-foreground">Travel Days</p>
                </div>
                <div className="bg-secondary rounded-lg p-3 text-center">
                  <p className="text-2xl font-bold text-accent">3</p>
                  <p className="text-xs text-muted-foreground">Routes Created</p>
                </div>
                <div className="bg-secondary rounded-lg p-3 text-center">
                  <p className="text-2xl font-bold text-accent">89</p>
                  <p className="text-xs text-muted-foreground">Followers</p>
                </div>
              </div>
            </div>

            <div className="bg-card rounded-xl p-4 border border-border">
              <h3 className="font-semibold text-card-foreground mb-3">Account Settings</h3>
              <ul className="space-y-2">
                {["Edit Profile", "Notification Preferences", "Privacy Settings", "Help & Support"].map((item) => (
                  <li key={item}>
                    <button className="w-full text-left py-2.5 px-3 rounded-lg text-sm text-card-foreground hover:bg-secondary transition-colors">
                      {item}
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          </section>
        )}
      </main>

      {/* Bottom Navigation */}
      <TabNavigation activeTab={activeTab} onTabChange={setActiveTab} />

      {/* Filter Sheet */}
      <FilterSheet 
        isOpen={isFilterOpen} 
        onClose={() => setIsFilterOpen(false)} 
      />
    </div>
  )
}
