import React from "react";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { MoreHorizontal, Search, Plus } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";

interface Client {
  id: string;
  name: string;
  status: "active" | "inactive";
  email: string;
  campaigns: number;
  lastActive: string;
}

interface ClientsTableProps {
  clients?: Client[];
  onSearch?: (query: string) => void;
}

const defaultClients: Client[] = [
  {
    id: "1",
    name: "Acme Corporation",
    status: "active",
    email: "contact@acme.com",
    campaigns: 12,
    lastActive: "2024-01-15",
  },
  {
    id: "2",
    name: "TechStart Inc",
    status: "active",
    email: "info@techstart.com",
    campaigns: 8,
    lastActive: "2024-01-14",
  },
  {
    id: "3",
    name: "Global Solutions Ltd",
    status: "inactive",
    email: "hello@globalsolutions.com",
    campaigns: 0,
    lastActive: "2023-12-20",
  },
  {
    id: "4",
    name: "Digital Dynamics",
    status: "active",
    email: "support@digitaldynamics.com",
    campaigns: 5,
    lastActive: "2024-01-12",
  },
];

const statusColors = {
  active: "bg-green-500",
  inactive: "bg-slate-500",
};

const ClientsTable = ({
  clients = defaultClients,
  onSearch = () => {},
}: ClientsTableProps) => {
  return (
    <Card className="w-full bg-slate-800 p-4 sm:p-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
        <div className="flex items-center gap-4">
          <h2 className="text-xl font-semibold text-white">Cliente</h2>
          <Button className="bg-slate-700 hover:bg-slate-600">
            <Plus className="h-4 w-4 mr-2" />
            Add Cliente
          </Button>
        </div>
        <div className="relative w-full sm:w-64">
          <Search className="absolute left-2 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder="Search clients..."
            className="pl-8 bg-slate-700 border-slate-600 text-white w-full"
            onChange={(e) => onSearch(e.target.value)}
          />
        </div>
      </div>

      <div className="rounded-md border border-slate-700 overflow-x-auto">
        <Table>
          <TableHeader>
            <TableRow className="border-slate-700">
              <TableHead className="text-slate-300">Nome do Cliente</TableHead>
              <TableHead className="text-slate-300">Status</TableHead>
              <TableHead className="text-slate-300 hidden sm:table-cell">
                Email
              </TableHead>
              <TableHead className="text-slate-300 text-right">
                Campaigns
              </TableHead>
              <TableHead className="text-slate-300 hidden md:table-cell">
                Last Active
              </TableHead>
              <TableHead className="text-slate-300 text-right">
                Actions
              </TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {clients.map((client) => (
              <TableRow key={client.id} className="border-slate-700">
                <TableCell className="font-medium text-white">
                  {client.name}
                </TableCell>
                <TableCell>
                  <Badge
                    variant="secondary"
                    className={`${statusColors[client.status]} text-white`}
                  >
                    {client.status}
                  </Badge>
                </TableCell>
                <TableCell className="hidden sm:table-cell text-slate-300">
                  {client.email}
                </TableCell>
                <TableCell className="text-right text-slate-300">
                  {client.campaigns}
                </TableCell>
                <TableCell className="hidden md:table-cell text-slate-300">
                  {client.lastActive}
                </TableCell>
                <TableCell className="text-right">
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button
                        variant="ghost"
                        className="h-8 w-8 p-0 text-slate-400 hover:text-white"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent
                      align="end"
                      className="bg-slate-800 text-white border-slate-700"
                    >
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700">
                        View Details
                      </DropdownMenuItem>
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700">
                        Edit Cliente
                      </DropdownMenuItem>
                      <DropdownMenuItem className="cursor-pointer hover:bg-slate-700 text-red-400">
                        Delete
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
};

export default ClientsTable;
