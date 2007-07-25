function operateHidden(newId,oldId){
  document.getElementById(oldId).style.display='none';
  document.getElementById(newId).style.display='';
  return newId;
}