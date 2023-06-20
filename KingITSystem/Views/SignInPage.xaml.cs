using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace KingITSystem.Views
{
    /// <summary>
    /// Логика взаимодействия для SignInPage.xaml
    /// </summary>
    public partial class SignInPage : Page
    {
        public SignInPage()
        {
            InitializeComponent();
        }

        private void loginButton_Click(object sender, RoutedEventArgs e)
        {
            string login = loginTextBox.Text;
            string password = "";
            if (passwordTextBox.Visibility == Visibility.Visible)
            {
                password = passwordTextBox.Password;
            }
            else
            {
                password = passwordShowTextBox.Text;
            }

            var CurrentUser = KingITEntities.GetContext().Users.FirstOrDefault(a => a.Login.ToLower() == login.ToLower() && a.Password == password);
            if (CurrentUser != null)
            {
                MessageBox.Show($"Вы вошли как {CurrentUser.Roles.RoleName}");

                NavigationService.Navigate(new ManagerCPage());
            }
            else
            {
                MessageBox.Show("Неправильный логин или пароль");
                return;
            }
        }

        private void CheckBox_Show(object sender, RoutedEventArgs e)
        {
            passwordShowTextBox.Text = passwordTextBox.Password;
            passwordTextBox.Visibility = Visibility.Collapsed;
            passwordShowTextBox.Visibility = Visibility.Visible;
        }

        private void CheckBox_Hide(object sender, RoutedEventArgs e)
        {
            passwordTextBox.Password = passwordShowTextBox.Text;
            passwordShowTextBox.Visibility = Visibility.Collapsed;
            passwordTextBox.Visibility = Visibility.Visible;
        }
    }
}
