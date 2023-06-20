using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для AddMallPage.xaml
    /// </summary>
    public partial class AddMallPage : Page
    {
        private Malls _currentMall = new Malls();  

        public AddMallPage(Malls selectedMall)
        {
            InitializeComponent();

            StatusesComboBox.ItemsSource = KingITEntities.GetContext().MallStatuses.ToList();
            CitiesComboBox.ItemsSource = KingITEntities.GetContext().Cities.ToList();

            if (selectedMall != null)
            {
                _currentMall = selectedMall;
            }

            DataContext = _currentMall;
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            if (_currentMall.MallId == 0)
            {
                KingITEntities.GetContext().Malls.Add(_currentMall);
            }
            try
            {
                KingITEntities.GetContext().SaveChanges();
                MessageBox.Show("Информация сохранена");
                NavigationService.GoBack();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

        private void GoBack_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }
    }
}
