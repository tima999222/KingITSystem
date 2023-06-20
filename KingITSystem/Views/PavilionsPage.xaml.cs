using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для PavilionsPage.xaml
    /// </summary>
    public partial class PavilionsPage : Page
    {
        public PavilionsPage()
        {
            InitializeComponent();
            DGridPavilions.ItemsSource = KingITEntities.GetContext().Pavilions.ToList();
            MallsComboBox.ItemsSource = KingITEntities.GetContext().Malls.ToList();
        }

        private void MallsComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var currentPavilions = KingITEntities.GetContext().Malls.ToList();

            if (MallsComboBox.SelectedIndex > 0)
            {
                var selectedMall = MallsComboBox.SelectedItem as Malls;
                currentPavilions = currentPavilions.Where(m => m.MallName.ToLower().Contains(selectedMall.MallName.ToLower())).ToList();
            }
            DGridPavilions.ItemsSource = currentPavilions;
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            var PavilionsToDelete = DGridPavilions.SelectedItems.Cast<Pavilions>().ToList();
            KingITEntities.GetContext().Pavilions.RemoveRange(PavilionsToDelete);
            try
            {
                KingITEntities.GetContext().SaveChanges();
                MessageBox.Show("Данные удалены");
                DGridPavilions.ItemsSource = KingITEntities.GetContext().Pavilions.ToList();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new AddPavilionPage(null));
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {

        }
    }
}
