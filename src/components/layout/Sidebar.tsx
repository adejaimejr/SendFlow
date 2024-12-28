import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { ScrollArea } from "@/components/ui/scroll-area";
import {
  LayoutDashboard,
  MessageSquare,
  Users,
  Settings,
  BarChart,
  X,
} from "lucide-react";
import { NavLink } from "react-router-dom";

interface SidebarProps extends React.HTMLAttributes<HTMLDivElement> {
  isOpen?: boolean;
  onClose?: () => void;
}

export function Sidebar({ className, isOpen, onClose }: SidebarProps) {
  return (
    <>
      {/* Mobile Overlay */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 lg:hidden z-40"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div
        className={cn(
          "pb-12 min-h-screen bg-slate-900",
          className,
          !isOpen && "-translate-x-full lg:translate-x-0",
        )}
      >
        <div className="flex items-center justify-between p-4">
          <h2 className="text-xl font-semibold text-slate-100">
            Campaign Manager
          </h2>
          {isOpen && (
            <Button
              variant="ghost"
              size="icon"
              className="lg:hidden text-slate-400 hover:text-slate-100"
              onClick={onClose}
            >
              <X className="h-5 w-5" />
            </Button>
          )}
        </div>

        <ScrollArea className="h-[calc(100vh-5rem)]">
          <div className="space-y-4 py-4">
            <div className="px-3 py-2">
              <div className="space-y-1">
                <NavLink to="/" end>
                  {({ isActive }) => (
                    <Button
                      variant={isActive ? "secondary" : "ghost"}
                      size="sm"
                      className={cn(
                        "w-full justify-start",
                        isActive
                          ? "bg-slate-800 text-slate-100 hover:bg-slate-800 hover:text-slate-100"
                          : "text-slate-400 hover:text-slate-100 hover:bg-slate-800/50",
                      )}
                      onClick={onClose}
                    >
                      <LayoutDashboard className="mr-2 h-4 w-4" />
                      Dashboard
                    </Button>
                  )}
                </NavLink>
                <NavLink to="/campaigns">
                  {({ isActive }) => (
                    <Button
                      variant={isActive ? "secondary" : "ghost"}
                      size="sm"
                      className={cn(
                        "w-full justify-start",
                        isActive
                          ? "bg-slate-800 text-slate-100 hover:bg-slate-800 hover:text-slate-100"
                          : "text-slate-400 hover:text-slate-100 hover:bg-slate-800/50",
                      )}
                      onClick={onClose}
                    >
                      <MessageSquare className="mr-2 h-4 w-4" />
                      Campaigns
                    </Button>
                  )}
                </NavLink>
                <NavLink to="/analytics">
                  {({ isActive }) => (
                    <Button
                      variant={isActive ? "secondary" : "ghost"}
                      size="sm"
                      className={cn(
                        "w-full justify-start",
                        isActive
                          ? "bg-slate-800 text-slate-100 hover:bg-slate-800 hover:text-slate-100"
                          : "text-slate-400 hover:text-slate-100 hover:bg-slate-800/50",
                      )}
                      onClick={onClose}
                    >
                      <BarChart className="mr-2 h-4 w-4" />
                      Analytics
                    </Button>
                  )}
                </NavLink>
                <NavLink to="/clients">
                  {({ isActive }) => (
                    <Button
                      variant={isActive ? "secondary" : "ghost"}
                      size="sm"
                      className={cn(
                        "w-full justify-start",
                        isActive
                          ? "bg-slate-800 text-slate-100 hover:bg-slate-800 hover:text-slate-100"
                          : "text-slate-400 hover:text-slate-100 hover:bg-slate-800/50",
                      )}
                      onClick={onClose}
                    >
                      <Users className="mr-2 h-4 w-4" />
                      Clients
                    </Button>
                  )}
                </NavLink>
                <NavLink to="/settings">
                  {({ isActive }) => (
                    <Button
                      variant={isActive ? "secondary" : "ghost"}
                      size="sm"
                      className={cn(
                        "w-full justify-start",
                        isActive
                          ? "bg-slate-800 text-slate-100 hover:bg-slate-800 hover:text-slate-100"
                          : "text-slate-400 hover:text-slate-100 hover:bg-slate-800/50",
                      )}
                      onClick={onClose}
                    >
                      <Settings className="mr-2 h-4 w-4" />
                      Settings
                    </Button>
                  )}
                </NavLink>
              </div>
            </div>
          </div>
        </ScrollArea>
      </div>
    </>
  );
}
