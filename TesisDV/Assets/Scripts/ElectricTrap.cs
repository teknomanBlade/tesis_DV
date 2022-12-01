using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ElectricTrap : Trap, IMovable, IInteractable
{
    [SerializeField] private float _damage;
    [SerializeField] private float _damagePerSecond;
    [SerializeField] private GameObject midPositionDamage;
    [SerializeField] private GameObject endPositionDamage;
    //[SerializeField] private float _trapDuration;
    [SerializeField] private float _currentLife;
    public ElectricityLineRenderer ElectricityLineRenderer;
    public GameObject blueprintPrefab;
    public GameObject ParticleLightning;
    private bool _isDisabledSFX;
    private AudioSource _as;
    private void Start()
    {
        _myTrapBase = transform.parent.GetComponent<TrapBase>();
        _myTrapBase.SetTrap(this.gameObject);
        GameVars.Values.IsAllSlotsDisabled();
        active = true; // Ahora las trampas empiezan encendidas.   
        _as = GetComponent<AudioSource>();
        ElectricityLineRenderer = GetComponent<ElectricityLineRenderer>();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "ElectricTrapSFX", 0.25f, true);
    }

    private void Update()
    {
        /* _trapDuration -= Time.deltaTime; La trampa ya no se apaga sola

        if (_trapDuration <=0)
        {
            active = false;
            ParticleLightning.SetActive(false);
            ElectricRadius.SetActive(false);
        } */
    }

    public void Interact()
    {
        if (!active)
        {
            active = true;
            GameVars.Values.soundManager.PlaySoundOnce(_as, "ElectricTrapSFX", 0.25f, true);
            ParticleLightning.SetActive(true);
            ElectricityLineRenderer.DisableEnableLightAndLineRenderer(true);
        }
        /* if(_trapDuration <= 0) La trampa ya no se apaga sola
        {
            _trapDuration =10f;
        } */
    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log("ENTRA EN COLLIDER...");
        var enemyGray = other.GetComponent<Enemy>();

        if (enemyGray && other.GetComponent<GrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 0.5f; 
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }
        if (enemyGray && other.GetComponent<TallGrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 1.5f;
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }
        if (enemyGray && other.GetComponent<TankGrayModel>() && active)
        {
            Debug.Log("ENTRA EN COLLIDER CON EL ENEMY: " + other.gameObject.name.ToUpper());
            _damage = 4f;
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }

    }

    private void OnTriggerStay(Collider other)
    {
        var enemyGray = other.GetComponent<Enemy>();

        if(enemyGray && !other.GetComponent<GrayModel>() && active)
        {
            other.GetComponent<Enemy>().TakeDamage(_damage);
        }
    }
    public override void Inactive()
    {
        if (!_isDisabledSFX) StartCoroutine(PlayShutdownSound());
        ParticleLightning.SetActive(false);
        ElectricityLineRenderer.DisableEnableLightAndLineRenderer(false);
        active = false;
    }

    IEnumerator PlayShutdownSound()
    {
        _isDisabledSFX = false;
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TurretShutDown", 0.16f, false);
        yield return new WaitForSeconds(1f);
        GameVars.Values.soundManager.StopSound();
        _isDisabledSFX = true;
    }

    public void BecomeMovable()
    {
        GameObject aux = Instantiate(blueprintPrefab, transform.position, transform.rotation);
        aux.GetComponent<StaticBlueprint>().SpendMaterials(false);
        aux.GetComponent<StaticBlueprint>().CanBeCancelled(false);
        _myTrapBase.ResetBase();
        Destroy(gameObject);
    }
}
