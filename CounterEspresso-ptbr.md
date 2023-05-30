id: acessibilidade-android-com-espresso
summary: Essa prática envolve configurar as dependências necessárias e escrever testes de acessibilidade usando Testes de UI com Espresso. Ao executar esses testes e analisar os resultados, você poderá identificar e corrigir problemas de acessibilidade em seu aplicativo.
authors: Anderson Canale Garcia
categories: Android
tags: beginner, developers, testers

# Aplicando Testes de UI com o Espresso para o projeto do app Counter
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

<!-- ------------------------ -->
## Configurando o projeto
Duration: 5

### O app Counter
Neste codelab, você trabalhará com um aplicativo existente, o Counter, derivado do [Google Codelabs] (https://developer.android.com/codelabs/starting-android-accessibility). Este aplicativo permite aos usuários rastrear, incrementar e decrementar uma contagem numérica. Embora o aplicativo seja simples, você descobrirá que ele tem alguns problemas de acessibilidade que podem dificultar que usuários com deficiência interajam com ele.

Você será orientado a executar as checagens de acessibilidade com o Espresso para identificar esses problemas rapidamente e corrigi-los.

### Clonando e abrindo o projeto
Você pode obter o código-fonte da versão inicial do aplicativo [neste link](https://github.com/andersongarcia/poor-accessibility-apps). Clone o repositório e abra Counter no Android Studio.

### Configure o projeto para usar o AATK
Siga os seguintes passos para preparar o projeto para adicionar testes de acessibilidade automatizados:

1. Edite o arquivo **build.gradle** da raíz, adicionando a seguinte linha na lista de repositories.

    <aside>
    <strong>Onde encontro isso?</strong> Ao abrir o projeto no Android Studio, na visualização do Android (painel esquerdo), há uma seção Gradle Scripts. Dentro, há um arquivo chamado build.gradle (Project: Counter).
    </aside>

    ```groovy
    allprojects {
        repositories {
            ...
            maven { url 'https://jitpack.io' }
        }
    }
    ```

2. Configure seu arquivo **build.gradle** no nível do aplicativo para habilitar a execulção de testes com o Robolectric e o AATK, atualizando os **testOptions** e adicionando as dependências necessárias.

    <aside>
    <strong>Onde encontro isso?</strong> Ao abrir o projeto no Android Studio, na visualização Android (painel esquerdo), há uma seção Gradle Scripts. Dentro, há um arquivo chamado <i>build.gradle (Módulo: Counter.app)</i>, ou algo parecido.
    </aside>

    Primeiro, adicione a diretiva **testOptions** com as seguintes linhas, dentro da diretiva **android**, assim:

    ```groovy
    android{
        ...
        testOptions {
            // Usado para testar elementos dependentes do Android na pasta de teste
            unitTests.includeAndroidResources  = true
            unitTests.returnDefaultValues = true
        }
    }
    ```

    Em seguida, adicione estas duas dependências como `testImplementation`:

    ```groovy
    dependencies {
        ...
        testImplementation 'org.robolectric:robolectric:4.9'
        testImplementation 'com.github.andersongarcia:android-accessibility-test-kit:v1.0.0-alpha'
        ...
    }
    ```

<aside><strong>Dica:</strong> leia mais sobre <a href="https://developer.android.com/studio/test/test-in-android-studio">Testes no Android Studio</a ></aside>


3. Depois de fazer essas alterações, sincronize seu projeto para garantir que elas entrem em vigor.
<!-- ------------------------ -->

## Crie uma classe de teste para a tela principal
Duration: 5
Nesta tarefa, você escreverá seus primeiros testes de acessibilidade com AATK.

### Criar a classe de teste
1. No Android Studio, abra o painel Project e encontre esta pasta:
* **com.example.android.accessibility.counter (test)**.

2. Clique com o botão direito na pasta **counter** e selecione **New** > **Java Class**

3. Nomeie como `MainActivityTest`. Assim você saberá que esta classe de teste se refere à `MainActivity`.

### Configurar a classe de teste
Com a classe `MainActivityTest` gerada e aberta, comece a configurá-la para executar os testes AATK.

1. Anote o escopo da classe para executar com `RoboletricTestRunner`.

2. Declare um atributo privado para manter o __rootView__ e o `AccessibilityTestRunner`.

3. Declare uma propriedade pública para o `ErrorCollector`.

4. Adicione um método **setUp** da seguinte forma:

    ```java
    @Before
    public void setUp() {
        MainActivity activity = Robolectric.buildActivity(MainActivity.class).create().get();

        // Obtenha a view raiz da hierarquia de exibição
        rootView = activity.getWindow().getDecorView().getRootView();
        runner = new AccessibilityTestRunner(collector);
    }
    ```

    <aside>O método com a anotação <strong>@Before</strong> sempre é executado antes da execução de cada caso de teste. Essa anotação é comumente usada para estabelecer as pré-condições necessárias para cada método <strong>@Test</strong>.</aside>

5. Neste ponto, seu `MainActivityTest` deve estar assim:

    ```java
    @RunWith(RobolectricTestRunner.class)
    public class MainActivityTest {
        private View rootView;
        private AccessibilityTestRunner runner;

        @Rule
        public ErrorCollector collector = new ErrorCollector();

        @Before
        public void setUp() {
            MainActivity activity = Robolectric.buildActivity(MainActivity.class).create().get();

            // Obtenha a view raiz da hierarquia de exibição
            rootView = activity.getWindow().getDecorView().getRootView();
            runner = new AccessibilityTestRunner(collector);
        }
    }
    ```
<!-- ------------------------ -->
## Escreva seu primeiro teste - Taxa de Contraste
Duration: 5

Adicione um método de teste para cada teste de acessibilidade que deseja executar. Começaremos com a verificação da taxa de contraste de cores.

### Crie um teste para verificar a taxa de contraste de cores

Uma taxa de contraste adequada ajuda os usuários a identificar melhor o conteúdo do aplicativo. Uma relação de contraste de pelo menos 4,5:1 deve ser usada.

Você pode utilizar o teste de taxa de contraste do **AATK** (`TestAdequateContrastRatio`) da seguinte forma:

1. Adicione um método de teste. Procure seguir boas convenções para nomenclatura de testes. Por exemplo: **deve_UsarTaxaDeContrasteAdequada**

2. Chame o método **runAccessibilityTest** do executor do kit, passando como parâmetro a view raíz e uma nova instância do teste desejado.

    ```java
        @Test
        public void deve_UsarTaxaDeContrasteAdequada(){
            runner.runAccessibilityTest(rootView, new TestAdequateContrastRatio());
        }
    ```

3. Execute seu teste. Clique com o botão direito do mouse sobre o nome do método e selecione **Run MainActivityTest.deve_UsarTaxaDeContrasteAdequada**

4. No painel **Run**, clique duas vezes em **deve_UsarTaxaDeContrasteAdequada** para ver os resultados. Você notará a mensagem de erro, a identificação `View`, a taxa esperada e a taxa atual.

    <aside>
    <strong>O que isso significa?</strong> No Counter, é fácil melhorar o contraste de cores. O TextView exibindo a contagem usa um plano de fundo cinza claro e uma cor de texto cinza. Você pode remover o plano de fundo, escolher um plano de fundo mais claro ou escolher uma cor de texto mais escura. Neste codelab, você escolherá uma cor de texto mais escura.
    </aside>

5. Abra o arquivo **res/layout/activity_main.xml**, encontre o **TextView** e altere **android:textColor="@color/grey"** para **android:textColor="@color/darkGrey"**.

    <aside>
    Os nomes dessas cores são uma predefinições desse projeto de exemplo. Para ver todas as cores pré-definidas, verifique o arquivo <strong>res/values/colors.xml</strong>.
    </aside>

6. Volte ao item **3** para refazer o teste e ver se ele passou.

<!-- ------------------------ -->
## Escreva novos testes
Duration: 5

Agora que já criou seu primeiro teste, você pode adicionar outros. A seguir, iremos sugerir mais dois exemplos. Consulte a [documentação do AATK](https://github.com/AALT-Framework/android-accessibility-test-kit) para consultar todos os testes disponíveis. 

### Crie um teste para verificar conteúdos não textuais sem descrição alternativa

Todo conteúdo não textual deve ter uma descrição de texto alternativa. Isso permite que um leitor de tela possa identificar corretamente o conteúdo.

Para esse teste, você irá utilizar o teste de texto alternativo do **AATK** (`TestMustHaveAlternativeText`), assim como fez para o teste de contraste.

1. Adicione um método de teste. Por exemplo: **deve_ConterAlternativaTextual**

2. Chame o método **runAccessibilityTest** do executor do kit, passando como parâmetro a view raíz e uma nova instância do teste desejado.

    ```java
        @Test
        public void deve_ConterAlternativaTextual(){
            runner.runAccessibilityTest(rootView, new TestMustHaveAlternativeText());
        }
    ```

3. Execute seu teste. Verifique os resultados. Realize as correções. Reexecute o teste.

    <aside>
    <strong>Dica:</strong> No Counter, os controles - e + não tem rótulos. Para corrigir esse problema, atribua uma android:contentDescription para cada botão.

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
    </aside>

### Crie um teste para verificar o tamanho dos alvos de toque

Todos os elementos de interação devem ter no mínimo 48x48dp.

Para esse teste, você irá utilizar o teste de texto alternativo do **AATK** (`TestTouchTargetSize`), assim como fez para os testes anteriores.

1. Adicione um método de teste. Por exemplo: **deve_AlvoDeToquePossuirTamanhoMinimo**

2. Chame o método **runAccessibilityTest** do executor do kit, passando como parâmetro a view raíz e uma nova instância do teste desejado.

    ```java
        @Test
        public void deve_AlvoDeToquePossuirTamanhoMinimo(){
            runner.runAccessibilityTest(rootView, new TestTouchTargetSize());
        }
    ```

3. Execute seu teste. Verifique os resultados. Realize as correções. Reexecute o teste.

    <aside>
    <strong>Dica:</strong> Em **res/layout/activity_main.xml**, podemos ver as seguintes definições para os dois botões:

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

    O valor de @dimen/icon_padding está definido como 12dp (veja res/dimens.xml). Quando o padding é aplicado, a área de toque do controle se torna 48dp x 48dp (24dp + 12dp em cada direção).
    </aside>