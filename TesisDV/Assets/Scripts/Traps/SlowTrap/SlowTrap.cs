using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowTrap : MonoBehaviour
{
    [SerializeField] private float _slowAmount;
    [SerializeField] private float _slowAmountPlayer;
    //[SerializeField] private float _destroyTime;
    [SerializeField] private bool _doesDamage;
    Animator _animator;
    private AudioSource _as;

    void Start()
    {
        _animator = GetComponent<Animator>();
        _as = GetComponent<AudioSource>();
        GameVars.Values.IsAllSlotsDisabled();
        GameVars.Values.soundManager.PlaySoundOnce(_as, "TarLiquidSFX", 0.15f, true);
    }

    void Update()
    {
        /*_destroyTime -= Time.deltaTime;

        if (_destroyTime <=0)
        {
            _animator.SetTrigger("IsDestroyed");
            GameVars.Values.soundManager.StopSound();
        }*/

        /* if (Input.GetKeyDown(KeyCode.G))
        {
            if (_doesDamage)
            {
                _doesDamage = false;
            }
            else
            {
                _doesDamage = true;
            }

        } */

        
    }

    public void DestroyTrap()
    {
        Destroy(gameObject);
    }

    void OnTriggerEnter(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 
        var player = other.GetComponent<Player>();

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(_slowAmount);
        }
        else if (player && other.GetComponent<Player>())
        {
            other.GetComponent<Player>().SlowDown(_slowAmountPlayer);
        }
    }

    void OnTriggerExit(Collider other)
    {
        var enemy = other.GetComponent<Enemy>(); //Despues hacer uno de estos para cada enemigo por ahora para ver cuanto sacale 
        var player = other.GetComponent<Player>();

        if (enemy)
        {
            other.GetComponent<Enemy>().SlowDown(-_slowAmount);
        }
        else if (player && other.GetComponent<Player>())
        {
            other.GetComponent<Player>().SlowDown(-_slowAmountPlayer);
        }
    }
}
