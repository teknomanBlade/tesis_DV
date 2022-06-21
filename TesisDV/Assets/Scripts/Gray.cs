//using System.Numerics;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.AI;

public class Gray : MonoBehaviour, IHittableObserver, IPlayerDamageObservable, IDoorGrayInteractObservable
{
    private List<IPlayerDamageObserver> _myObserversPlayerDamage = new List<IPlayerDamageObserver>();
    private List<IDoorGrayInteractObserver> _myObserversDoorGrayInteract = new List<IDoorGrayInteractObserver>();
    [SerializeField]
    private GameObject _player;
    private Player _playerScript;
    [SerializeField]
    private float _movingSpeed;
    private AudioSource _as;
    [SerializeField]
    private Animator _anim;
    private Rigidbody _rb;
    private CapsuleCollider _cc;
    private LevelManager _lm;
    private NavMeshAgent _navMeshAgent;
    private NavMeshPath _navMeshPath;
    private bool _isWalkingSoundPlaying = false;
    private bool _isMoving;
    private bool _hasHitEffectActive = false;
    private float _attackWindup = 1.333f;
    public float distanceToPlayer;
    public float pursueThreshold = 10f;
    public float disengageThreshold = 15f;
    public float attackThreshold = 2.5f;
    public float attackDisengageThreshold = 3f;
    private List<Transform> _waypoints;
    private int _currentWaypoint = 0;
    private int _currentCorner = 0;
    public Coroutine attackCoroutine;
    public Coroutine currentCoroutine;
    public bool dead = false;
    public bool attacking = false;
    public bool pursue = false;
    public bool stun = false;
    public bool skillEMP = false;
    public bool awake = false;
    public int hp = 3;
    public bool hasObjective = false;
    private Vector3 _exitPos;
    private Vector3 _currentObjective;
    private float nearestDoorDistance = 1000;
    private Transform nearestDoor;
    private Vector3 nearestDoorVector;
    private bool canCreatePath;

    /*[SerializeField]
    private Material deathMaterial;*/

    [SerializeField]
    private Material dissolveMaterial;
    [SerializeField]
    private Material sphereEffectMaterial;

    private SkinnedMeshRenderer skinned;
    private float _valueToChange;

    [SerializeField]
    private ParticleSystem _empAbility;

    [SerializeField]
    private ParticleSystem _hitEffect;

    [SerializeField]
    private ParticleSystem _deathEffect;
    private void Awake()
    {
        canCreatePath = false;
        _anim = GetComponent<Animator>();
        _anim.SetBool("IsSpawning", true);
        _rb = GetComponent<Rigidbody>();
        _cc = GetComponent<CapsuleCollider>();
        _as = GetComponent<AudioSource>();
        _player = GameVars.Values.Player.gameObject;
        _playerScript = GameVars.Values.Player;
        AddObserver(_playerScript);
        AddObserverDoorGrayInteract(_playerScript);
        _lm = GameObject.Find("GameManagement").GetComponent<LevelManager>();
        //_empAbility = GameObject.Find("EMPAbility").GetComponent<ParticleSystem>();
        //_isMoving = true;
        _empAbility.Stop();
        _deathEffect.Stop();
        _navMeshAgent = GetComponent<NavMeshAgent>();
        skinned = GetComponentInChildren<SkinnedMeshRenderer>();
        nearestDoorDistance = 1000;
        _lm.AddGray(this);

        //Exit pos lo setea el UFO en el instantiate.
       /*  Vector3 aux = _lm.allUfos[0].transform.position;
        _exitPos = new Vector3(aux.x, 0f, aux.z); */
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
            /*if (skillEMP)
            {
                _anim.SetBool("IsEMP", true);
            }
            else
            {*/
            //_anim.SetBool("IsEMP", false);
            if (!stun)
            {
                _anim.SetBool("IsStunned", false);
                distanceToPlayer = Vector3.Distance(_player.transform.position, transform.position);

                if (IsInSight() && !_lm.enemyHasObjective)
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

                    if (!_isWalkingSoundPlaying)
                        StartCoroutine(PlayGraySound());

                    //_anim.SetBool("IsWalking", true); Ahora en MovingAnimations()
                }
                else
                {
                    pursue = false;
                    _isWalkingSoundPlaying = false;
                    //_anim.SetBool("IsWalking", false); Ahora en MovingAnimations()
                }

                if(canCreatePath)
                {
                    _navMeshAgent.ResetPath();
                    CalculatePath(_currentObjective);
                   //_currentCorner = 0;
                    canCreatePath = false;
                }

                if(_isMoving)
                {
                    ReliableMove();
                    //Move();
                }
                MovingAnimations();
                CheckPathStatus();

                if (!_lm.enemyHasObjective && Vector3.Distance(transform.position, _lm.objective.transform.position) < 3f)
                {
                    GrabObjective();
                    GameVars.Values.ShowNotification("The cat has been captured! You must prevent the grays getting to the ship!");
                }
                if (_lm.enemyHasObjective && Vector3.Distance(transform.position, _exitPos) < 3f)
                {
                    GoBackToShip();
                }
                if (hasObjective) MoveObjective();
            }
            else
            {
                pursue = false;
                _isWalkingSoundPlaying = false;
                _isMoving = false;
            }
            //}
        }
    }
    public void EndSpawnAnim()
    {
        _anim.SetBool("IsSpawning", false);
    }
    public void Move()
    {
        Vector3 dest = default(Vector3);
        if (pursue)
        {
            //CalculatePath(_player.transform.position);
            canCreatePath = true;
            _currentObjective = _player.transform.position;
            MoveTo();
            //dest = _player.transform.position;
        }
        else if (_lm.enemyHasObjective) 
        {
            //CalculatePath(_exitPos);
            canCreatePath = true;
            _currentObjective = _exitPos;
            MoveTo();
            //dest = _exitPos;
        }
        else if (_lm.allDoorsAreClosed)
        {
            StartCoroutine(FindClosestDoor());
            
            dest = nearestDoor.position;
            if (Vector3.Distance(transform.position, nearestDoorVector) < 3f)
            {
                //_anim.SetBool("IsAttacking", true);
                currentCoroutine = StartCoroutine(PlayAnimation("IsAttacking", "Attack"));
                nearestDoor.GetComponent<AuxDoor>().Interact();
                GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(nearestDoor.GetComponent<AuxDoor>().myDoor.itemName));
                TriggerDoorGrayInteract("GrayDoorInteract");
                StartCoroutine(LerpOutlineWidthAndColor(8f,2f, Color.red));
                _lm.ChangeDoorsStatus();
            }
            
        }
        else
        {
            //CalculatePath(_lm.objective.transform.position);
            canCreatePath = true;
            _currentObjective = _lm.objective.transform.position;
            MoveTo();
            //dest = _lm.objective.transform.position;
        }

        var dir = dest - transform.position;
        dir.y = 0f;

        //_navMeshAgent.destination = dest;
    }

    IEnumerator PlayAnimation(string param, string name)
    {
        _anim.SetBool(param, true);
        var clips = _anim.runtimeAnimatorController.animationClips;
        float time = clips.First(x => x.name == name).length;
        yield return new WaitForSeconds(time);
        _anim.SetBool(param, false);
    }

    public void ReliableMove()
    {
        Vector3 dest = default(Vector3);
        if (pursue)
        {
            dest = _player.transform.position;
        }
        else if (_lm.enemyHasObjective) 
        {
            dest = _exitPos;
        }
        else if (_lm.allDoorsAreClosed)
        {
            StartCoroutine(FindClosestDoor());
            
            dest = nearestDoor.position;
            if (Vector3.Distance(transform.position, nearestDoorVector) < 3f)
            {
                _anim.SetBool("IsAttacking", true);
                
                nearestDoor.GetComponent<AuxDoor>().Interact();
                GameVars.Values.ShowNotification("The Grays have entered through the " + GetDoorAccessName(nearestDoor.GetComponent<AuxDoor>().myDoor.itemName));
                TriggerDoorGrayInteract("GrayDoorInteract");
                StartCoroutine(LerpOutlineWidthAndColor(8f,2f, Color.red));
                _lm.ChangeDoorsStatus();
            }
            
        }
        else
        {
            dest = _lm.objective.transform.position;
        }

        var dir = dest - transform.position;
        dir.y = 0f;

        _navMeshAgent.destination = dest;
    }

    public void MovingAnimations()
    {
        if(_isMoving)
        _anim.SetBool("IsWalking", true);
        else
        _anim.SetBool("IsWalking", false);
    }

    public string GetDoorAccessName(string name)
    {
        var result = "";
        if (name.Contains("Red"))
        {
            result = "Red Access Door.";
        }
        else if (name.Contains("Black"))
        {
            result = "Black Access Door.";
        }
        else if (name.Contains("White"))
        {
            result = "White Access Door.";
        }
        return result;
    }

    public void CheckPathStatus()
    {
        if(_navMeshAgent.pathStatus == NavMeshPathStatus.PathPartial || _navMeshAgent.pathStatus == NavMeshPathStatus.PathInvalid)
        {
            //_isMoving = false;

        }
        else
        {
            _isMoving = true;
        }
    }

    public IEnumerator PlayGraySound()
    {
        GameVars.Values.soundManager.PlaySoundOnce(_as,"VoiceWhispering", 0.4f, true);
        yield return new WaitForSeconds(.01f);
        _isWalkingSoundPlaying = true;
    }

    public IEnumerator PlayGrayDeathSound()
    {
         _anim.SetBool("IsDead", true);
        SwitchDissolveMaterial(dissolveMaterial);
        GameVars.Values.soundManager.PlaySoundOnce(_as, "GrayDeathSound", 0.4f, true);
        yield return new WaitForSeconds(1.6f);
        GameVars.Values.soundManager.StopSound();
        yield return new WaitForSeconds(2.5f);
        yield return StartCoroutine(LerpScaleDissolve(0f, 1.5f)); 
        Dead();
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
            if (distanceToPlayer > disengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > pursueThreshold) return false;
        }
        return true;
    }

    private bool CanAttack()
    {
        if (!IsInSight()) return false;
        if (attacking)
        {
            if (distanceToPlayer > attackDisengageThreshold) return false;
        }
        else
        {
            if (distanceToPlayer > attackThreshold) return false;
        }
        return true;
    }
    public void SwitchDissolveMaterial(Material material)
    {
        var materials = skinned.sharedMaterials.ToList();
        materials.Clear();
        materials.Add(material);
        skinned.sharedMaterials = materials.ToArray();
    }

    IEnumerator Attack()
    {
        attacking = true;
        _isMoving = false;
        StartCoroutine(PlayAnimation("IsAttacking", "Attack"));
        //_anim.SetBool("IsAttacking", true);
        yield return new WaitForSeconds(_attackWindup);
        TriggerPlayerDamage("DamagePlayer");
        PlayParticleSystemShader();
        attacking = false;
        _isMoving = true;
        //attackCoroutine = StartCoroutine("Attack");
        //_anim.SetBool("IsAttacking", false);
    }

    public void PlayParticleSystemShader()
    {
        _empAbility.Play();
    }

    public void Stun(float time)
    {
        //_anim.SetBool("IsHitted", false);
        _rb.isKinematic = true;
        _rb.velocity = Vector3.zero;
        _isMoving = false;
        stun = true;
        currentCoroutine = StartCoroutine(PlayAnimation("IsStunned", "Stun"));
        //_anim.SetBool("IsStunned", true);
        Invoke("UnStun", time);
    }

    public void SecondStun(float time)
    {
        //_anim.SetBool("IsHitted", false);
        stun = true;
        _isMoving = false;
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        currentCoroutine = StartCoroutine(PlayAnimation("IsStunned", "Stun"));
        _rb.isKinematic = true;
        Invoke("SecondUnStun", time);
    }

    private void MoveTo()
    {
        
            //Vector3 dir = _waypoints[_currentWaypoint].position - transform.position;
            //Debug.Log(_navMeshAgent.path.corners.Length);
            if(_currentCorner < _navMeshAgent.path.corners.Length)
            {
                Vector3 dir = _navMeshAgent.path.corners[_currentCorner] - transform.position;
                transform.forward = dir;
                transform.position += transform.forward * _movingSpeed * Time.deltaTime;
            }

            if (Vector3.Distance(transform.position, _navMeshAgent.path.corners[_currentCorner]) <= .1f)  //dir.magnitude < 0.1f
            {
                if(_currentCorner + 1 > _navMeshAgent.path.corners.Length)
                {
                    // -------------------
                    canCreatePath = true;
                    _currentCorner = 0;
                }
                else
                {
                    Mathf.Clamp(_currentCorner, 0 , _navMeshAgent.path.corners.Length);
                    _currentCorner++;
                    Mathf.Clamp(_currentCorner, 0 , _navMeshAgent.path.corners.Length);
                }
                //_currentWaypoint++;
                

                /* if (_currentCorner > _navMeshAgent.path.corners.Length) //-1
                {
                    //_currentWaypoint = 0;
                    
                    canCreatePath = true;
                    _currentCorner = 0;
                } */

            }
        
    
    }

    public void UnStun()
    {
        _rb.isKinematic = false;
        stun = false;
        _isMoving = false;
    }

    public void SecondUnStun()
    {

        Vector3 dest = default(Vector3);
        if (pursue) dest = _player.transform.position;
        else if (_lm.enemyHasObjective) dest = _exitPos;
        else dest = _lm.objective.transform.position;
        _rb.isKinematic = false;
        stun = false;
        _isMoving = false;
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

    public void GrabObjective()
    {
        hasObjective = true;
        _anim.SetBool("IsGrab", true);
        GameVars.Values.TakeCat(_exitPos);
        _lm.CheckForObjective();
    }

    public void MoveObjective()
    {
        //CAMBIAR PARA QUE EL GATO QUEDE ENTRE LAS MANOS.
        if(_lm.objective != null) _lm.objective.transform.position = transform.position + new Vector3(0f, 1.8f - 0.35f, -0.87f);
    }

    public void DropObjective()
    {
        _lm.objective.transform.position = transform.position + new Vector3(0f, 0.75f, 0f);
        hasObjective = false;
        GameVars.Values.SetCatFree();
        _lm.CheckForObjective();
    }

    public void GoBackToShip()
    {
        if (hasObjective)
        {
            _lm.LoseGame();
            Destroy(_lm.objective);
        }
        _lm.RemoveGray(this);
        //_lm.EnemyCameBack();
        Destroy(gameObject);
    }

    public void Die()
    {
        dead = true;
        var spawnPos = new Vector3(transform.position.x, transform.position.y + 8f, transform.position.z);
        var UFO = GameVars.Values.LevelManager.UFOsPool.GetObject().InitializePosition(spawnPos);
        StartCoroutine(PlayGrayDeathSound());
        _navMeshAgent.destination = transform.position;
        if (hasObjective)
        {
            DropObjective();
        }
        awake = false;
        _rb.isKinematic = true;
        _cc.enabled = false;
        _lm.RemoveGray(this);
        _lm.CheckForObjective();
    }

    public void PlayShaderDissolve()
    {
        
    }

    public void PlayPostDeath()
    {
        _anim.SetBool("IsPostDeath", true);
        //StartCoroutine(LerpScaleDissolve(0f, 1f));
    }

    public void Dead()
    {
        dissolveMaterial.SetFloat("_ScaleDissolveGray", 1);
        Destroy(gameObject);
    }

    public Vector3 GetVelocity()
    {
        return _navMeshAgent.velocity;
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

    public void OnNotify(string message)
    {
        if (message.Equals("TennisBallHit"))
        {
            //_anim.SetBool("IsHitted", true);
            currentCoroutine = StartCoroutine(PlayAnimation("IsHitted", "Hit"));
            ActiveInnerEffect();
            StartCoroutine(LerpSphereHitEffect(2f,2f));
            GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
            Damage();
            Stun(5f);
        }
        else if (message.Equals("RacketHit"))
        {
            if (_anim)
            {
                currentCoroutine = StartCoroutine(PlayAnimation("IsHitted", "Hit"));
                ActiveInnerEffect();
                StartCoroutine(LerpSphereHitEffect(2f, 2f));
                GameVars.Values.soundManager.PlaySoundAtPoint("BallHit", transform.position, 0.45f);
                Damage();
                Stun(5f);
            }
        }
    }

    public void ActiveInnerEffect()
    {
        _hitEffect.Play();
        _hasHitEffectActive = true;
        var meshRenderer = _hitEffect.gameObject.transform.GetComponentInChildren<MeshRenderer>();
        meshRenderer.enabled = _hasHitEffectActive;
        sphereEffectMaterial = meshRenderer.sharedMaterials.FirstOrDefault();
    }

    IEnumerator FindClosestDoor()
    {
        nearestDoorDistance = 1000f;

        foreach (Transform door in _lm.allDoors)
        {
            if (Vector3.Distance(transform.position, door.position) < nearestDoorDistance)
            {
                nearestDoorDistance = Vector3.Distance(transform.position, door.position);
                nearestDoor = door;
                nearestDoorVector = door.position;

            }

        }
        yield return new WaitForSeconds(0.5f);
    }

    IEnumerator LerpSphereHitEffect(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            sphereEffectMaterial.SetFloat("_Interpolator", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
        yield return new WaitForSeconds(1.5f);
        sphereEffectMaterial.SetFloat("_Interpolator", 0);
        _hasHitEffectActive = false;
        _hitEffect.gameObject.transform.GetComponentInChildren<MeshRenderer>().enabled = _hasHitEffectActive;
    }

    IEnumerator LerpScaleDissolve(float endValue, float duration)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            dissolveMaterial.SetFloat("_ScaleDissolveGray", _valueToChange);
            yield return null;
        }

        _valueToChange = endValue;
    }
    IEnumerator LerpOutlineWidthAndColor(float endValue, float duration, Color color)
    {
        float time = 0;
        float startValue = _valueToChange;

        while (time < duration)
        {
            _valueToChange = Mathf.Lerp(startValue, endValue, time / duration);
            time += Time.deltaTime;

            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineColor = color;
            nearestDoor.GetComponent<AuxDoor>().myDoor.GetComponent<Outline>().OutlineWidth = _valueToChange;
            yield return null;
        }

        _valueToChange = endValue;
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.red));
        yield return new WaitForSeconds(0.5f);
        yield return StartCoroutine(LerpOutlineWidthAndColor(0f, 2f, Color.green));
    }
    public Gray SetExitUFO(Vector3 exitPosition)
    {
        Vector3 aux = exitPosition;
        _exitPos = new Vector3(aux.x, 0f, aux.z);
        
        return this;
    }

    private void CalculatePath(Vector3 targetPosition)
    {
        _navMeshAgent.ResetPath();  
        NavMeshPath path = new NavMeshPath();
        //_navMeshAgent.CalculatePath(targetPosition, path);
        if(NavMesh.CalculatePath(transform.position, _currentObjective, NavMesh.AllAreas, path))
        {
            _navMeshAgent.SetPath(path);
        }
        
        //NavMesh.CalculatePath(transform.position, targetPosition, NavMesh.AllAreas, _navMeshPath)
    }

    public void AddObserver(IPlayerDamageObserver obs)
    {
        _myObserversPlayerDamage.Add(obs);
    }

    public void RemoveObserver(IPlayerDamageObserver obs)
    {
        if (_myObserversPlayerDamage.Contains(obs)) _myObserversPlayerDamage.Remove(obs);
    }

    public void TriggerPlayerDamage(string triggerMessage)
    {
        _myObserversPlayerDamage.ForEach(x => x.OnNotifyPlayerDamage(triggerMessage));
    }

    public void AddObserverDoorGrayInteract(IDoorGrayInteractObserver obs)
    {
        _myObserversDoorGrayInteract.Add(obs);
    }

    public void RemoveObserverDoorGrayInteract(IDoorGrayInteractObserver obs)
    {
        if (_myObserversDoorGrayInteract.Contains(obs)) _myObserversDoorGrayInteract.Remove(obs);
    }

    public void TriggerDoorGrayInteract(string triggerMessage)
    {
        _myObserversDoorGrayInteract.ForEach(x => x.OnNotifyDoorGrayInteract(triggerMessage));
    }
}
