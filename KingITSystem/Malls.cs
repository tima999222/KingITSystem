//------------------------------------------------------------------------------
// <auto-generated>
//     Этот код создан по шаблону.
//
//     Изменения, вносимые в этот файл вручную, могут привести к непредвиденной работе приложения.
//     Изменения, вносимые в этот файл вручную, будут перезаписаны при повторном создании кода.
// </auto-generated>
//------------------------------------------------------------------------------

namespace KingITSystem
{
    using System;
    using System.Collections.Generic;
    
    public partial class Malls
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2214:DoNotCallOverridableMethodsInConstructors")]
        public Malls()
        {
            this.Pavilions = new HashSet<Pavilions>();
        }
    
        public int MallId { get; set; }
        public string MallName { get; set; }
        public int MallStatusId { get; set; }
        public int CityId { get; set; }
        public decimal BuildingCost { get; set; }
        public int LevelsCount { get; set; }
        public decimal ValueAddedFactor { get; set; }
    
        public virtual Cities Cities { get; set; }
        public virtual MallStatuses MallStatuses { get; set; }
        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Usage", "CA2227:CollectionPropertiesShouldBeReadOnly")]
        public virtual ICollection<Pavilions> Pavilions { get; set; }
    }
}