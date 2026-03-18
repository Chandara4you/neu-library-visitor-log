// js/auth.js — Auth helpers (used if you split into modules)
export function getVisitor(){ return JSON.parse(localStorage.getItem('neu_visitor')||'null'); }
export function getAdmin(){   return JSON.parse(localStorage.getItem('neu_admin')||'null'); }
export function clearVisitor(){ localStorage.removeItem('neu_visitor'); }
export function clearAdmin(){   localStorage.removeItem('neu_admin'); }
export function requireVisitor(){ if(!getVisitor()) window.location.href='login.html'; return getVisitor(); }
export function requireAdmin(){   if(!getAdmin())   window.location.href='login.html'; return getAdmin(); }
