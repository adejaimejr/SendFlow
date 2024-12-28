import { Bell, User, Menu } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface HeaderProps {
  title: string;
  showPeriodSelector?: boolean;
  selectedPeriod?: string;
  onPeriodChange?: (value: string) => void;
  onMenuClick?: () => void;
}

export function Header({
  title,
  showPeriodSelector = false,
  selectedPeriod = "7d",
  onPeriodChange = () => {},
  onMenuClick,
}: HeaderProps) {
  return (
    <header className="sticky top-0 z-40 w-full border-b border-slate-700 bg-slate-900/95 backdrop-blur supports-[backdrop-filter]:bg-slate-900/75">
      <div className="px-3 sm:px-4 md:px-6 flex h-14 items-center justify-between">
        <div className="flex items-center gap-3">
          <Button
            variant="ghost"
            size="icon"
            className="lg:hidden text-slate-400 hover:text-slate-100"
            onClick={onMenuClick}
          >
            <Menu className="h-5 w-5" />
          </Button>
          <h1 className="text-base sm:text-lg font-semibold text-slate-100">
            {title}
          </h1>
        </div>

        <div className="flex items-center gap-2 sm:gap-4">
          {showPeriodSelector && (
            <Select value={selectedPeriod} onValueChange={onPeriodChange}>
              <SelectTrigger className="w-[140px] sm:w-[180px] bg-slate-800 text-white border-slate-700 hidden sm:flex text-sm">
                <SelectValue placeholder="Select period" />
              </SelectTrigger>
              <SelectContent className="bg-slate-800 text-white border-slate-700">
                <SelectItem value="24h">Last 24 Hours</SelectItem>
                <SelectItem value="7d">Last 7 Days</SelectItem>
                <SelectItem value="30d">Last 30 Days</SelectItem>
                <SelectItem value="90d">Last 90 Days</SelectItem>
                <SelectItem value="custom">Custom Range</SelectItem>
              </SelectContent>
            </Select>
          )}

          <Button
            variant="ghost"
            size="icon"
            className="text-slate-400 hover:text-slate-100 hidden sm:flex"
          >
            <Bell className="h-4 w-4 sm:h-5 sm:w-5" />
          </Button>

          <Button
            variant="ghost"
            size="icon"
            className="text-slate-400 hover:text-slate-100"
          >
            <User className="h-4 w-4 sm:h-5 sm:w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
