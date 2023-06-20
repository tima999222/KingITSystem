using System;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Navigation;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для AddPavilionPage.xaml
    /// </summary>
    public partial class AddPavilionPage : Page
    {
        private Pavilions _currentPavilion = new Pavilions();
        private bool _isCreate = true;

        public AddPavilionPage(Pavilions selectedPavilion)
        {
            InitializeComponent();
            MallsComboBox.ItemsSource = KingITEntities.GetContext().Malls.ToList();
            PavilionStatusesComboBox.ItemsSource = KingITEntities.GetContext().Pavilions.ToList();

            if (selectedPavilion != null)
            {
                _currentPavilion = selectedPavilion;
                _isCreate = false;
            }
            DataContext = _currentPavilion;
        }

        private void GoBack_Click(object sender, RoutedEventArgs e)
        {
            NavigationService.GoBack();
        }

        private void SaveButton_Click(object sender, RoutedEventArgs e)
        {
            if (_isCreate == true)
            {
                KingITEntities.GetContext().Pavilions.Add(_currentPavilion);
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
    }
}
