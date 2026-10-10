variable "records" {
  type        = map(object({ zone_id = string, name = string, type = string, content = string, ttl = optional(number, 1), proxied = optional(bool, false), priority = optional(number) }))
  description = "A, AAAA, CNAME, TXT, MX, or NS records keyed by stable identifiers; TTL 1 means automatic."
  nullable    = false
  validation {
    condition     = alltrue([for record in values(var.records) : can(regex("^[a-f0-9]{32}$", record.zone_id)) && length(trimspace(record.name)) > 0 && length(trimspace(record.content)) > 0 && contains(["A", "AAAA", "CNAME", "TXT", "MX", "NS"], record.type) && (record.ttl == 1 || (record.ttl >= 60 && record.ttl <= 86400 && floor(record.ttl) == record.ttl)) && (!record.proxied || (contains(["A", "AAAA", "CNAME"], record.type) && record.ttl == 1)) && (record.type == "MX" ? (record.priority != null ? record.priority >= 0 && record.priority <= 65535 && floor(record.priority) == record.priority : false) : record.priority == null) && (record.type == "A" ? can(cidrnetmask("${record.content}/32")) : true) && (record.type == "AAAA" ? strcontains(record.content, ":") && can(cidrhost("${record.content}/128", 0)) : true)])
    error_message = "Supply supported records with valid zone IDs, content, TTL, proxy settings, IPv4/IPv6 values, and MX-only priorities."
  }
}
