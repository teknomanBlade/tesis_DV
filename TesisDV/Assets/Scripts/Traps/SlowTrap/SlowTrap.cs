using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTrap : MonoBehaviour
{
    [SerializeField] private float _slowAmount;
    [SerializeField] private float _slowAmountPlayer;
    [SerializeField] private float _slow20BoostCoefMultiplier;
    [SerializeField] private float _slow30BoostCoefMultiplier;
    [SerializeField] private bool _doesDamage;
    private MeshRenderer _tarStainMR;
    private ParticleSystem _bubblesParticleSystem;
    #region Upgrades
    [Header("Upgrades")]
    public float TenPercentDamage;
    public float TwentyPercentDamage;
    [SerializeField] private GameObject _plus20SlowBlueprint;
    [SerializeField] private GameObject _plus20SlowUpgrade;
    [SerializeField] private GameObject _plus30SlowBlueprint;
    [SerializeField] private GameObject _plus30SlowUpgrade;
    [SerializeField] private GameObject _minus10PercentPoisonDamageBlueprint;
    [SerializeField] private GameObject _minus10PercentPoisonDamageUpgrade;
    [SerializeField] private GameObject _minus20PercentPoisonDamageBlueprint;
    [SerializeField] private GameObject _minus20PercentPoisonDamageUpgrade;
    [SerializeField] private GameObject _tarStain;
    [SerializeField] private GameObject _bubblesParticles;
    public bool _canActivate1aUpgrade { get; private set; }
    public bool _canActivate2aUpgrade { get; private set; }
    public bool _canActivate1bUpgrade { get; private set; }
    public bool _canActivate2bUpgrade { get; private set; }
    private SkillTree _skillTree;

    #endregion
    Animator _animator;
    private AudioSource _as;

    void Awake()
    {
        _slowAmount = 2.5f;
        _tarStainMR = _tarStain.GetComponent<MeshRenderer>();
        _bubblesParticleSystem = _bubblesParticles.GetComponent<ParticleSystem>();
        _skillTree = GameVars.Values.craftingContainer.gameObject.GetComponentInChildren<SkillTree>(true);
        _skillTree.OnUpgrade += CheckForUpgrades;
        CheckForUpgrades();
        _animator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        GameVars.Values.IsAllSlotsDisabled();
        Invoke(nameof(ActiveInitSound),7.0f);
        
    }

    void Update()
    {
            
    }

    public void DestroyTrap()
    {
        Destroy(gameObject);
    }
    
    public void ActiveInitSound() 
    {
        GameVars.Values.soundManager.PlaySound(_as, "TarLiquidSFX", 0.15f, true,1f);
    }
    void OnTriggerEnter(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            TenPercentDamage = enemy.HP * 0.01f;
            TwentyPercentDamage = enemy.HP * 0.02f;
            if (_canActivate1aUpgrade)
            {
                if (enemy.enemyType == EnemyType.Dog)
                    Debug.Log("SLOW DOWN GRAY DOG 1A? " + enemy.name);

                var new20PercentSlow = enemy._movingSpeed / _slow20BoostCoefMultiplier;
                other.GetComponent<Enemy>().SlowDown(new20PercentSlow);
            }
            else if (_canActivate1bUpgrade)
            {
                if (enemy.enemyType == EnemyType.Dog)
                    Debug.Log("SLOW DOWN GRAY DOG 1B? " + enemy.name);

                var new30PercentSlow = enemy._movingSpeed / _slow30BoostCoefMultiplier;
                other.GetComponent<Enemy>().SlowDown(new30PercentSlow);
            }
            else 
            {
                if(enemy.enemyType == EnemyType.Dog)
                    Debug.Log("SLOW DOWN GRAY DOG? " + enemy.name);

                var basicSlow = enemy._movingSpeed / _slowAmount;
                other.GetComponent<Enemy>().SlowDown(basicSlow);
            }
        }
    }
    private void OnTriggerStay(Collider other)
    {
        var enemy = other.GetComponent<Enemy>();

        if (enemy) 
        {
            if (_canActivate2aUpgrade) 
            {
                enemy.PoisonHitted = true;
                Debug.Log("10 PERCENT DAMAGE: " + TenPercentDamage);
                enemy.TakeDamage(TenPercentDamage);
            }
            else if (_canActivate2bUpgrade) 
            {
                enemy.PoisonHitted = true;
                Debug.Log("20 PERCENT DAMAGE: " + TwentyPercentDamage);
                enemy.TakeDamage(TwentyPercentDamage);
            }
        }
    }
    void OnTriggerExit(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 

        if (enemy)
        {
            enemy.SlowDebuffFade();
        }
    }

    #region Upgrade Voids
    private void CheckForUpgrades()
    {
        if (_skillTree.isST1aActivated)
        {
            Debug.Log("UPGRADE 1A BOUGHT");
            Activate1aUpgrade();
        }
        if (_skillTree.isST1bActivated)
        {
            Debug.Log("UPGRADE 1B BOUGHT");
            Activate1bUpgrade();
        }
        if (_skillTree.isST2aActivated)
        {
            Debug.Log("UPGRADE 2A BOUGHT");
            ChangeColorToStainAndBubbles();
            Activate2aUpgrade();

        }
        if (_skillTree.isST2bActivated)
        {
            Debug.Log("UPGRADE 2B BOUGHT");
            ChangeColorToStainAndBubbles();
            Activate2bUpgrade();
        }
    }

    /*public bool IsBothUpgradesActive() 
    {
        return (_canActivate1aUpgrade && _canActivate1bUpgrade);
    }*/

    public void ChangeColorToStainAndBubbles() 
    {
        _tarStainMR.material.SetFloat("_TarUpgradeTransition", 1f);
        ParticleSystem.MainModule main = _bubblesParticleSystem.main;
        main.startColor = new Color(0f, 0.427451f, 0.1886792f,1f);
    }

    public void Activate1aUpgrade()
    {
        _canActivate1aUpgrade = true;
        _slow20BoostCoefMultiplier = 2f;
    }
    public void Activate1bUpgrade()
    {
        _canActivate1bUpgrade = true;
        _canActivate1aUpgrade = false;
        _slow30BoostCoefMultiplier = 1.5f;
    }

    public void Activate2aUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = true;
    }
    public void Activate2bUpgrade()
    {
        _canActivate1bUpgrade = false;
        _canActivate1aUpgrade = false;
        _canActivate2aUpgrade = false;
        _canActivate2bUpgrade = true;
    }

    #endregion
}
