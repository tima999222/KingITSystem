using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для MallsPage.xaml
    /// </summary>
    public partial class MallsPage : Page
    {
        public MallsPage()
        {
            InitializeComponent();
            var MallsList = KingITEntities.GetContext().Malls.ToList();
            DGridMalls.ItemsSource = MallsList;

            var StatusesList = KingITEntities.GetContext().MallStatuses.ToList();
            StatusesList.Insert(0, new MallStatuses { MallStatus = "Все статусы" });

            StatusesComboBox.ItemsSource = StatusesList;
            StatusesComboBox.SelectedIndex = 0;

            var CitiesList = KingITEntities.GetContext().Cities.ToList();
            CitiesList.Insert(0, new Cities { CityName = "Все города" });

            CitiesComboBox.ItemsSource = CitiesList;
            CitiesComboBox.SelectedIndex = 0;
        }

        private void StatusesComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var currentMalls = KingITEntities.GetContext().Malls.ToList();

            if (StatusesComboBox.SelectedIndex > 0)
            {
                var selectedStatus = StatusesComboBox.SelectedItem as MallStatuses;
                currentMalls = currentMalls.Where(m => m.MallStatuses.MallStatus.ToLower().Contains(selectedStatus.MallStatus.ToLower())).ToList();
            }
            DGridMalls.ItemsSource = currentMalls;
        }

        private void CitiesComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            var currentMalls = KingITEntities.GetContext().Malls.ToList();

            if (CitiesComboBox.SelectedIndex > 0)
            {
                var selectedCities = CitiesComboBox.SelectedItem as Cities;
                currentMalls = currentMalls.Where(m => m.Cities.CityName.ToLower().Contains(selectedCities.CityName.ToLower())).ToList();
            }
            DGridMalls.ItemsSource = currentMalls;
        }

        private void AddButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new AddMallPage(null));
        }

        private void DeleteButton_Click(object sender, RoutedEventArgs e)
        {
            var MallsToDelete = DGridMalls.SelectedItems.Cast<Malls>().ToList();
            KingITEntities.GetContext().Malls.RemoveRange(MallsToDelete);
            try
            {
                KingITEntities.GetContext().SaveChanges();
                MessageBox.Show("Данные удалены");
                DGridMalls.ItemsSource = KingITEntities.GetContext().Malls.ToList();
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.ToString());
            }
        }

        private void EditButton_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.Navigate(new AddMallPage((sender as Button).DataContext as Malls));
        }
    }
}
