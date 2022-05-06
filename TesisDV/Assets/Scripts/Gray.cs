using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Gray : MonoBehaviour
{
    [SerializeField]
    private GameObject _player;
    private Player _playerScript;
    private Animator _anim;
    private Rigidbody _rb;
    private LevelManager _lm;
    private NavMeshAgent _navMeshAgent;
    private ParticleSystem _empAbility;
    private bool _isWalkingSoundPlaying = false;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;
    public float attackWindup = 1f;
    public Coroutine attackCoroutine;
    public bool attacking = false;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;
    public bool awake = false;
    public int hp = 3;
    public bool hasObjective = false;

    private void Awake()
    {
        _anim = GetComponent<Animator>();
        _rb = GetComponent<Rigidbody>();
        _player = GameObject.Find("Player");
        _playerScript = _player.GetComponent<Player>();
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        _empAbility = GameObject.Find("EMPAbility").GetComponent<ParticleSystem>();
        _empAbility.Stop();
        _navMeshAgent = GetComponent<NavMeshAgent>();
        _lm.AddGray(this);
    }

    private void Start()
    {
        //for testing
        //Invoke("Die", 0.5f);
    }

    private void Update()
    {
        if (_player == null)
        {
            StopAllCoroutines();
            awake = false;
        }
        if (awake)
        {
            if (skillEMP)
            {
                _anim.SetBool("IsEMP", true);
            }
            else
            {
                _anim.SetBool("IsEMP", false);
                if (!stun)
                {
                    _anim.SetBool("IsStunned", false);
                    distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);

                    if (IsInSight())
                    {
                        if (CanAttack())
                        {
                            if (attackCoroutine == null) attackCoroutine = StartCoroutine("Attack");
                        }
                        else
                        {
                            if (attackCoroutine != null)
                            {
                                StopCoroutine(attackCoroutine);
                                attackCoroutine = null;
                                attacking = false;
                            }
                        }
                        pursue = true;
                        _anim.SetBool("IsWalking", true);
                    }
                    else
                    {
                        pursue = false;
                        _anim.SetBool("IsWalking", false);
                    }

                    Move();

                }
                else
                {
                    pursue = false;
                    _isWalkingSoundPlaying = false;
                }
            }
        }
    }

    public void Move()
    {
        Vector3 dest = default(Vector3);
        if (pursue) dest = _player.transform.position;
        else if (_lm.enemyHasObjective) dest = _lm.allUfos[0].transform.position;
        else dest = _lm.objective.transform.position;

        var dir = _player.transform.position - transform.position;
        dir.y = 0f;
        transform.forward = dir;
        //transform.position += transform.forward * 3f * Time.deltaTime;
        //_rb.velocity = transform.forward * 2f;
        _navMeshAgent.destination = dest;

        /*if (_isWalkingSoundPlaying)
        {
           GameVars.Values.soundManager.PlaySoundOnce("VoiceWhispering", 0.4f, true);
        }
        _isWalkingSoundPlaying = false;*/
    }

    private bool IsInSight()
    {
        LayerMask layermask = 1 << 12;
        layermask = layermask << 3;
        if (Physics.Raycast(transform.position, _player.transform.position, disengageThreshold, layermask))
        {
            return false;
        }
        if (pursue)
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > disengageThreshold) return false;
        } else
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > pursueThreshold) return false;
        }
        _isWalkingSoundPlaying = true;
        return true;
    }

    private bool CanAttack()
    {
        if (!IsInSight()) return false;
        if (attacking)
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > attackDisengageThreshold) return false;
        } else
        {
            if (Vector3.Distance(_player.transform.position, transform.position) > attackThreshold) return false;
        }
        return true;
    }

    IEnumerator Attack()
    {
        attacking = true;
        yield return new WaitForSeconds(attackWindup);
       
        _playerScript.Damage();
        attacking = false;
        attackCoroutine = StartCoroutine("Attack");
    }

    public void PlayParticleSystemShader()
    {
        _empAbility.Play();
    }

    public void Stun(float time)
    {
        _rb.isKinematic = true;
        stun = true;
        _anim.SetBool("IsStunned", true);
        Invoke("UnStun", time);
    }

    public void UnStun()
    {
        _rb.isKinematic = false;
        stun = false;
    }

    public void SetPos(Vector3 pos)
    {
        transform.position = pos;
    }

    public void AwakeGray()
    {
        awake = true;
    }

    public void Damage()
    {
        Stun(0.2f);
        hp--;
        if (hp <= 0) Die();
    }

    public void Exit()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
        }
        awake = false;
        _lm.EnemyDied();
        _lm.RemoveGray(this);
        Destroy(gameObject);
    }

    public void Die()
    {
        if (hasObjective)
        {
            hasObjective = false;
        }
        awake = false;
        _rb.isKinematic = true;
        _anim.SetBool("IsDead", true);
        _lm.EnemyDied();
        _lm.RemoveGray(this);
        _lm.CheckForObjective();
        Invoke("Dead", 3f);
    }

    public void Dead()
    {
        Destroy(gameObject);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireSphere(transform.position, attackThreshold);
        Gizmos.DrawWireSphere(transform.position, attackDisengageThreshold);
        Gizmos.color = Color.white;
        Gizmos.DrawWireSphere(transform.position, pursueThreshold);
        Gizmos.DrawWireSphere(transform.position, disengageThreshold);
        Gizmos.DrawRay(transform.position, _player.transform.position - transform.position);
    }
}
