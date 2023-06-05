id: acessibilidade-android-com-espresso
summary: Essa prática envolve configurar as dependências necessárias e escrever testes de acessibilidade usando Testes de UI com Espresso. Ao executar esses testes e analisar os resultados, você poderá identificar e corrigir problemas de acessibilidade em seu aplicativo.
authors: Anderson Canale Garcia
categories: Android
tags: beginner, developers, testers

# Aplicando Testes de UI com o Espresso para o projeto do app Contador
<!-- ------------------------ -->
## Introdução
Duration: 1

Os aplicativos __mobile__ podem ajudar as pessoas a realizar tarefas diárias. No entanto, pessoas com deficiência podem enfrentar várias barreiras ao usar os recursos desses dispositivos se eles não fornecerem acessibilidade adequada.

Os desenvolvedores de software desempenham um papel crucial na promoção de melhorias de acessibilidade digital, e os testes automatizados podem ajudá-los.

O **Espresso** é um framework de teste de interface do usuário para aplicativos Android, permitindo que os desenvolvedores criem testes automatizados para interagir com os elementos da interface do usuário do aplicativo. É integrado com o Android Studio e pode ser executado em dispositivo físico ou emulado. 

Para testar acessibilidade com o Espresso, é possível usar a API AccessibilityChecks do Framework de Testes de Acessibilidade (ATF, na sigla em inglês). 

Algumas das checagens realizadas pelo ATF incluem:

* Verificar se todos os elementos da interface do usuário têm rótulos de conteúdo e descrições de texto adequados.
* Verificar se a ordem de foco dos elementos da interface do usuário é lógica e previsível.
* Verificar se a taxa de contraste dos elementos da interface do usuário são suficientes.
* Verificar se as ações do usuário na interface do usuário podem ser realizadas com gestos de toque ou com um teclado.
* Verificar se a interface do usuário é compatível com os recursos de acessibilidade do Android, como o TalkBack e o modo de alto contraste.

### O que você aprenderá
Ao realizar este codelab, você será capaz de:
1. configurar um projeto existente para usar o Espresso
2. criar uma classe de teste instrumentado e habilitar as checagens de acessibilidade
3. executar um teste que realize as checagens de acessibilidade
4. identificar e corrigir problemas de acessibilidade

### Pré-requisitos
Não é necessário nenhum conhecimento prévio sobre acessibilidade ou testes automatizados para realizar este codelab. No entanto, assumimos que você:
1. possui o Android Studio instalado em seu ambiente de desenvolvimento
2. seja capaz de baixar o projeto do GitHub e abrir no Android Studio
3. você vai precisar de um dispositivo físico ou emulado

<!-- ------------------------ -->
## Configurando o projeto
Duration: 5

### O app Contador
Neste codelab, você trabalhará com um aplicativo existente, o Contador, derivado do Google Codelabs. Este aplicativo permite aos usuários rastrear, incrementar e decrementar uma contagem numérica. Embora o aplicativo seja simples, você descobrirá que ele tem alguns problemas de acessibilidade que podem dificultar que usuários com deficiência interajam com ele.

Você será orientado a executar as checagens de acessibilidade com o Espresso para identificar esses problemas rapidamente e corrigi-los.

### Clonando e abrindo o projeto
Você pode obter o código-fonte da versão inicial do aplicativo [neste link](https://github.com/andersongarcia/poor-accessibility-apps). Clone o repositório e abra **Contador** no Android Studio.

### Configure o projeto para habilitar o AccessibilityChecks
Você precisará de uma nova dependência para o pacote **androidTestImplementation**. Confira se a linha seguinte já foi adicionada para você no arquivo **app/build.gradle**.

1. Edite o arquivo **build.gradle** da raíz, adicionando a seguinte linha na lista de dependencias.

    <aside>
    <strong>Onde encontro isso?</strong> Ao abrir o projeto no Android Studio, na visualização Android (painel esquerdo), há uma seção Gradle Scripts. Dentro, há um arquivo chamado <i>build.gradle (Módulo: Contador.app)</i>, ou algo parecido.
    </aside>

    ```groovy
    dependencies {
        ...
        androidTestImplementation 'androidx.test.espresso:espresso-accessibility:3.3.0-alpha05'        
        ...
    }
    ```

<aside><strong>Dica:</strong> leia mais sobre <a href="https://developer.android.com/studio/test/test-in-android-studio">Testes no Android Studio</a ></aside>


3. Depois de fazer essas alterações, sincronize seu projeto para garantir que elas entrem em vigor.
<!-- ------------------------ -->

## Crie uma classe de teste instrumentado para a tela principal
Duration: 5
Nesta tarefa, você criará uma classe de teste instrumentado e habilitará as checagens de acessibilidade.

### Criar a classe de teste
1. No Android Studio, abra o painel Project e encontre esta pasta:
* **com.example.contador (androidTest)**.

2. Clique com o botão direito na pasta **contador** e selecione **New** > **Java Class**

3. Nomeie como `MainActivityInstrumentedTest`. Assim você saberá que esta classe de teste instrumentado se refere à `MainActivity`.

### Configurar a classe de teste
Com a classe `MainActivityInstrumentedTest` gerada e aberta, crie seu primeiro teste. Para o propósito deste codelab, será escrito apenas um único teste, que verifica se o código para incrementar a contagem funciona corretamente (por questões de brevidade, o teste para decrementar a contagem foi omitido). Sua classe deverá ficar assim:

```java
public class MainActivityInstrumentedTest {
    @Rule
    public ActivityScenarioRule<MainActivity> mActivityTestRule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void testIncrement(){
        Espresso.onView(withId(R.id.add_button))
            .perform(ViewActions.click());
        Espresso.onView(withId(R.id.countTV))
            .check(matches(withText("1")));
    }
}
```

### Execute o teste
Primeiro, verifique se o seu computador está conectado a um dispositivo com a depuração USB ativada.

Agora execute os testes clicando no botão de seta verde imediatamente à esquerda de @Test fun testIncrement(). Se você estiver usando um dispositivo físico conectado via USB, certifique-se de que o dispositivo esteja desbloqueado e com a tela ligada. Observe que pressionar Ctrl+Shift+F10 (Control+Shift+R em um Mac) executa os testes no arquivo atualmente aberto.

O teste deve ser executado até o final e deve passar, confirmando que o incremento da contagem funciona como esperado.

Na próxima seção, você irá modificar o teste para verificar também a acessibilidade.

<!-- ------------------------ -->
## Habilite as checagens de acessibilidade com o Espresso
Duration: 5

Com o Espresso, você pode habilitar verificações de acessibilidade chamando **AccessibilityChecks.enable()** de um método de configuração. Adicionar essa única linha de código permite que você teste sua interface do usuário para acessibilidade, tornando fácil integrar a verificação de acessibilidade em seu conjunto de testes.

### Crie um teste para verificar a taxa de contraste de cores

Para configurar a classe `MainActivityInstrumentedTest` para checagens de acessibilidade, aficione o seguinte método de configuração antes do seu teste.

```java
    @BeforeClass
    public static void beforeClass()
    {
        AccessibilityChecks.enable();
    }

```

Agora execute o teste novamente. Desta vez, você perceberá que o teste falha. No painel **Run**, clique duas vezes em **testIncrement** para ver os resultados. Você notará a mensagem de erro.

### Entendendo a falha do teste

O teste falhou porque o ATF encontrou duas oportunidades para melhorar a acessibilidade do aplicativo:

1. O ImageButton de adição ("+") contém uma imagem, mas não tem um rótulo. Ele precisa de um rótulo para que um usuário de leitor de tela possa entender o propósito do botão.

2. O ImageButton também precisa de um alvo de toque maior para que os usuários com destreza manual limitada possam interagir com o botão com mais facilidade.


### Melhorando sua interface do usuário

Nesta etapa, você fará alterações no arquivo **res/layout/activity_main.xml** para atender às sugestões do ATF que estão causando falhas nos seus testes (lembre-se de que o ATF encontrou duas oportunidades para melhorar a acessibilidade, incluindo um rótulo e o aumento do tamanho do alvo de toque):

Primeiro, você irá adicionar um rótulo ao botão de adicionar.

Abra o arquivo **res/layout/activity_main.xml** e procure o código do primeiro ImageButton (você notará um aviso do lint sobre a falta de **contentDescription**):
```xml
    <ImageButton 
        android:id="@+id/subtract_button"
        ...
        android:contentDescription="@string/decrement" />

    <ImageButton
        android:id="@+id/add_button"
        ...
        android:contentDescription="@string/increment" />
```

Use strings localizadas nas descrições de conteúdo. Assim, elas poderão ser adequadamente traduzidas. Para este codelab, as strings já foram definidas em res/values/strings.xml.

Execute o teste novamente e você não verá mais uma falha relacionada ao rótulo do botão.

Agora você irá abordar a outra recomendação do ATF, que se refere ao tamanho do alvo de toque do botão. O tamanho de toque para o botão é de 24x24dp, e a mensagem de falha do teste indica que o tamanho de toque mínimo recomendado é de 48x48dp.

Você tem várias opções para aumentar a área sensível ao toque dos botões. Por exemplo, você pode fazer o seguinte:

Em **res/layout/activity_main.xml**, podemos ver as seguintes definições para os dois botões:

```xml
    <ImageButton
        android:id="@+id/add_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        ... />

    <ImageButton
        android:id="@+id/subtract_button"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        ... />
```

Adicione um pouco de padding a cada visualização:

```xml
    <ImageButton
        ...
        android:padding="@dimen/icon_padding"
        ... />

    <ImageButton
        ...
        android:padding="@dimen/icon_padding"
        ... />
```

O valor de **@dimen/icon_padding** está definido como 12dp (veja res/dimens.xml). Quando o padding é aplicado, a área de toque do controle se torna 48dp x 48dp (24dp + 12dp em cada direção).

Execute o teste novamente. A falha do teste relacionada aos alvos de toque não ocorre mais, portanto o teste é aprovado.